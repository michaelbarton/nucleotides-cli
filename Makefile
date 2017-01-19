path := PATH=$(abspath .tox/py27-build/bin):$(PATH)

version := $(shell $(path) python setup.py --version)
name    := $(shell $(path) python setup.py --name)
dist    := .tox/dist/$(name)-$(version).zip

installer-image := test-install

# Which branch to fetch input data files from. This can be overridden to fetch
# files from a difference git branch. E.g. `make bootstrap DATA-BRANCH=dev`
DATA-BRANCH=master

.PHONY: test autotest bootstrap clean


#################################################
#
# Setup credentials for testing
#
#################################################


docker_host := $(shell echo ${DOCKER_HOST} | egrep -o "\d+.\d+.\d+.\d+")

# Configure POSTGRES host based on whether boot2docker or native docker is being used
ifdef docker_host
       db_host  := POSTGRES_HOST=//$(docker_host):5433
else
       db_host     := POSTGRES_HOST=//localhost:5433
       docker_host := localhost
endif

# Fake user created for testing database
db_user := POSTGRES_USER=postgres
db_pass := POSTGRES_PASSWORD=pass
db_name := POSTGRES_NAME=postgres

# AWS keys used to send test data
aws_pass   = AWS_SECRET_ACCESS_KEY=$(shell bundle exec ./plumbing/fetch_credential secret_key)
aws_key    = AWS_ACCESS_KEY_ID=$(shell bundle exec ./plumbing/fetch_credential access_key)
aws_region = AWS_DEFAULT_REGION=us-west-1

params = NUCLEOTIDES_API=$(docker_host) $(db_user) $(db_pass) $(db_name) $(db_host) $(aws_pass) $(aws_key) $(aws_region)

# Makefile macro shortcut to run docker images with all credentials configured.
docker_db := @docker run \
	--env="$(db_user)" \
	--env="$(db_name)" \
	--env="PGHOST=$(docker_host)" \
	--env="PGPASSWORD=pass" \
	--env="PGUSER=postgres" \
	--env="PGPORT=5433" \
	--env="PGDATABASE=postgres" \
	--env=POSTGRES_HOST=//localhost:5433 \
	--volume=$(abspath tmp/data/db_fixture):/data:ro \
	--net=host


#################################################
#
# Build and upload python package
#
#################################################


publish: $(dist)
	@mkdir -p tmp/dist
	@cp $< tmp/dist/nucleotides-client.zip
	@docker run \
		--tty \
		--volume=$(abspath tmp/dist):/dist:ro \
		--env=AWS_ACCESS_KEY=$(shell bundle exec ./plumbing/fetch_credential access_key) \
		--env=AWS_SECRET_KEY=$(shell bundle exec ./plumbing/fetch_credential secret_key) \
		--entrypoint=/push-to-s3 \
		bioboxes/file-deployer \
		nucleotides-tools client $(version) /dist/nucleotides-client.zip

build: $(dist) test-build

test-build:
	tox -e py27-build

ssh: $(dist)
	@docker run \
		--interactive \
		--tty \
		--volume=$(abspath $(dir $^)):/dist:ro \
		$(installer-image) \
		/bin/bash

$(dist): $(shell find bin nucleotides) requirements/default.txt setup.py MANIFEST.in
	@tox --sdistonly

#################################################
#
# Run tests and features
#
#################################################

test = $(params) tox -e py27-unit

slow_feature: Gemfile.lock $(credentials) test-build
	@$(path) $(params) TMPDIR=$(abspath tmp/aruba) \
		bundle exec cucumber features/all_commands.feature

feature: Gemfile.lock $(credentials) test-build
	@$(path) $(params) TMPDIR=$(abspath tmp/aruba) \
		bundle exec cucumber \
		--require features/support/ \
		--require features/steps/ \
		--exclude features/all_commands.feature $(ARGS)

test:
	@$(test) $(ARGS)

wip:
	@$(test) -- -a 'wip' $(ARGS)

fast_test:
	@clear && $(test) -- -a '!slow'

autotest:
	@clear && $(test) -- -a '!slow' || true # Using true starts tests even on failure
	@fswatch -o ./nucleotides -o ./test | xargs -n 1 -I {} bash -c "clear && $(test) -a '!slow'"

################################################
#
# Create artificial dataset for testing nucleotides client
#
################################################


# Minimal set of files required to migrate the database
test-data := \
	tmp/data/db_fixture/inputs/image.yml \
	tmp/data/db_fixture/inputs/benchmark.yml \
	tmp/data/db_fixture/inputs/data/test_organism.yml \
	tmp/data/db_fixture/controlled_vocabulary/extraction_method.yml \
	tmp/data/db_fixture/controlled_vocabulary/file.yml \
	tmp/data/db_fixture/controlled_vocabulary/image.yml \
	tmp/data/db_fixture/controlled_vocabulary/material.yml \
	tmp/data/db_fixture/controlled_vocabulary/metric.yml \
	tmp/data/db_fixture/controlled_vocabulary/platform.yml \
	tmp/data/db_fixture/controlled_vocabulary/protocol.yml \
	tmp/data/db_fixture/controlled_vocabulary/run_mode.yml \
	tmp/data/db_fixture/controlled_vocabulary/source.yml \


data-url = https://raw.githubusercontent.com/nucleotides/nucleotides-data/$(DATA-BRANCH)/


# Copy dummy input files into testing directory
tmp/data/db_fixture/%: example_data/%
	@mkdir -p $(dir $@)
	@printf $(WIDTH) "  --> Copying example input file '$*'"
	@cp $< $@
	@$(OK)


# Fetch metadata files from github
# Keep this dependency target below `tmp/data/db_fixture/%` so that example data
# files are copied over first
tmp/data/db_fixture/controlled_vocabulary/%:
	@mkdir -p $(dir $@)
	@printf $(WIDTH) "  --> Fetching nucleotides metadata file '$*'"
	@wget --quiet $(data-url)/controlled_vocabulary/$* --output-document $@
	@$(OK)




# Create an SQL which can be used to reset the database to an example state
tmp/data/fixtures.sql: .rdm_container $(test-data)
	@printf $(WIDTH) "  --> Creating nucleotid.es fixture dataset"
	@$(docker_db) \
	  --entrypoint=psql \
	  kiasaki/alpine-postgres:9.5 \
	  --command="drop schema public cascade; create schema public;" \
	  2> log/migration.txt > log/migration.txt
	@$(docker_db) \
	  --env="$(db_pass)" \
	  nucleotides/api:staging \
	  migrate \
	  2>> log/migration.txt >> log/migration.txt
	@$(docker_db) \
	  --entrypoint=pg_dump \
	  kiasaki/alpine-postgres:9.5 \
	  --inserts | grep -v 'SET row_security = off;' > $@
	@$(OK)


################################################
#
# Bootstrap required project resources
#
################################################

# Test data must be downloaded first otherwise the Docker daemon sets the
# `tmp/data` directory as root when mounting it as a volume
bootstrap: \
	$(test-data) \
	Gemfile.lock \
	.api_container \
	.deploy_image \
	tmp/data/assembly_metrics.tsv \
	tmp/data/fixtures.sql
	@docker pull bioboxes/crash-test-biobox 2>&1 > /dev/null

# Fetch example input data from S3
tmp/data/%: ./plumbing/fetch_s3_file Gemfile.lock
	@$(shell mkdir -p $(dir $@))
	@bundle exec $< s3://nucleotides-testing/short-read-assembler/$* $@


# Launch nucleotides API container, connnected to the RDS container
.api_container: .rdm_container .api_image
	@printf $(WIDTH) "  --> Launching nucleotid.es API container"
	@$(docker_db) \
		--detach=true \
		--net=host \
		--publish 80:80 \
		nucleotides/api:staging \
		server > $@
	@$(OK)


# Launch POSTGRES RDS container
.rdm_container: .rdm_image
	@printf $(WIDTH) "  --> Launching POSTGRES RDS container"
	@docker run \
		--env="$(db_user)" \
		--env="$(db_pass)" \
		--publish=5433:5432 \
		--detach=true \
		kiasaki/alpine-postgres:9.5 \
		> $@
	@sleep 3
	@$(OK)


.api_image:
	@printf $(WIDTH) "  --> Fetching nucleotid.es API Docker image"
	@docker pull nucleotides/api:staging 2>&1 > /dev/null
	@touch $@
	@$(OK)

.rdm_image:
	@printf $(WIDTH) "  --> Fetching Postgres RDS Docker image"
	@docker pull kiasaki/alpine-postgres:9.5 2>&1 > /dev/null
	@touch $@
	@$(OK)

.deploy_image:
	@printf $(WIDTH) "  --> Fetching Docker image to publish client"
	@docker pull bioboxes/file-deployer 2>&1 > /dev/null
	@$(OK)

Gemfile.lock: Gemfile
	@printf $(WIDTH) "  --> Fetching ruby dependencies for feature tests"
	@mkdir -p log
	@bundle install --path vendor/bundle 2>&1 > log/bundle.txt
	@$(OK)

clean:
	@docker kill $(shell cat .rdm_container 2> /dev/null) 2> /dev/null; true
	@docker kill $(shell cat .api_container 2> /dev/null) 2> /dev/null; true
	@rm -f .*_container .*_image Gemfile.lock
	@rm -rf tmp log


################################################
#
# Colours to format makefile target outputs
#
################################################

OK=echo " $(GREEN)OK$(END)"
WIDTH="%-70s"

RED="\033[0;31m"
GREEN=\033[0;32m
YELLOW="\033[0;33m"
END=\033[0m
