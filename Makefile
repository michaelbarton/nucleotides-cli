path := PATH=$(abspath .tox/py27-build/bin):$(PATH)

version := $(shell $(path) python setup.py --version)
name    := $(shell $(path) python setup.py --name)
dist    := .tox/dist/$(name)-$(version).zip

installer-image := test-install

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
aws_pass   := AWS_SECRET_ACCESS_KEY=$(shell bundle exec ./plumbing/fetch_credential secret_key)
aws_key    := AWS_ACCESS_KEY_ID=$(shell bundle exec ./plumbing/fetch_credential access_key)
aws_region := AWS_DEFAULT_REGION=us-west-1

params := NUCLEOTIDES_API=$(docker_host) $(db_user) $(db_pass) $(db_name) $(db_host) $(aws_pass) $(aws_key) $(aws_region)

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
	--volume=$(abspath tmp/data/nucleotides):/data:ro \
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

feature: Gemfile.lock $(credentials) test-build
	@$(path) $(params) TMPDIR=$(abspath tmp/aruba) bundle exec cucumber $(ARGS)

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
# Bootstrap required project resources
#
################################################

bootstrap: \
	Gemfile.lock \
	.api_container \
	.deploy_image \
	tmp/data/11948b41d44931c6a25cabe58b138a4fc7ecc1ac628c40dcf1ad006e558fb533 \
	tmp/data/6bac51cc35ee2d11782e7e31ea1bfd7247de2bfcdec205798a27c820b2810414 \
	tmp/data/dummy.reads.fq.gz \
	tmp/data/assembly_metrics.tsv \
	tmp/data/contigs.fa \
	tmp/data/fixtures.sql


tmp/data/%: ./plumbing/fetch_s3_file
	$(shell mkdir -p $(dir $@))
	bundle exec $^ s3://nucleotides-testing/short-read-assembler/$* $@

tmp/data/fixtures.sql: tmp/data/nucleotides .rdm_container
	$(docker_db) \
	  --entrypoint=psql \
	  kiasaki/alpine-postgres:9.5 \
	  --command="drop schema public cascade; create schema public;"
	$(docker_db) \
	  --env="$(db_pass)" \
	  nucleotides/api:staging \
	  migrate
	$(docker_db) \
	  --entrypoint=pg_dump \
	  kiasaki/alpine-postgres:9.5 \
	  --inserts | grep -v 'SET row_security = off;' > $@

tmp/data/nucleotides: data/crash_test_image.yml
	rm -rf $@
	mkdir -p $(dir $@)
	git clone https://github.com/nucleotides/nucleotides-data.git $@
	rm $@/inputs/data/*
	cp data/test_organism.yml $@/inputs/data/
	cp data/benchmark.yml $@/inputs/
	cp data/crash_test_image.yml $@/tmp
	tail -n +2 $@/inputs/image.yml >> $@/tmp
	mv $@/tmp $@/inputs/image.yml


.api_container: .rdm_container .api_image
	@docker run \
	  --detach=true \
	  --env="$(db_user)" \
	  --env="$(db_pass)" \
	  --env="$(db_name)" \
	  --env=POSTGRES_HOST=//localhost:5433 \
	  --net=host \
	  --publish 80:80 \
	  nucleotides/api:staging \
	  server > $@

.rdm_container: .rdm_image
	docker run \
		--env="$(db_user)" \
		--env="$(db_pass)" \
		--publish=5433:5432 \
		--detach=true \
		kiasaki/alpine-postgres:9.5 \
		> $@
	sleep 3

.rdm_image:
	docker pull kiasaki/alpine-postgres:9.5
	touch $@

.api_image:
	docker pull nucleotides/api:staging
	touch $@

.deploy_image:
	docker pull bioboxes/file-deployer

Gemfile.lock: Gemfile
	mkdir -p log
	bundle install --path vendor/bundle 2>&1 > log/bundle.txt

clean:
	@docker kill $(shell cat .rdm_container 2> /dev/null) 2> /dev/null; true
	@docker kill $(shell cat .api_container 2> /dev/null) 2> /dev/null; true
	@rm -f .*_container .*_image Gemfile.lock
	@rm -rf vendor tmp .bundle log

.PHONY: test autotest bootstrap clean
