path := PATH=$(abspath ./vendor/python/bin):$(shell echo "${PATH}")

version := $(shell $(path) python setup.py --version)
name    := $(shell $(path) python setup.py --name)
dist    := dist/$(name)-$(version).tar.gz

installer-image := test-install

docker_host := $(shell echo ${DOCKER_HOST} | egrep -o "\d+.\d+.\d+.\d+")

ifdef docker_host
       db_host  := POSTGRES_HOST=//$(docker_host):5433
else
       db_host     := POSTGRES_HOST=//localhost:5433
       docker_host := localhost
endif

db_user := POSTGRES_USER=postgres
db_pass := POSTGRES_PASSWORD=pass
db_name := POSTGRES_NAME=postgres

aws_pass   := AWS_SECRET_ACCESS_KEY=$(shell bundle exec ./plumbing/fetch_credential secret_key)
aws_key    := AWS_ACCESS_KEY_ID=$(shell bundle exec ./plumbing/fetch_credential access_key)
aws_region := AWS_DEFAULT_REGION=us-west-1

params := NUCLEOTIDES_API=$(docker_host) $(db_user) $(db_pass) $(db_name) $(db_host) $(aws_pass) $(aws_key) $(aws_region)

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
	@cp $< $(dir $<)/nucleotides-client.tar.gz
	@docker run \
		--tty \
		--volume=$(abspath $(dir $<)):/dist:ro \
		--env=AWS_ACCESS_KEY=$(shell bundle exec ./plumbing/fetch_credential access_key) \
		--env=AWS_SECRET_KEY=$(shell bundle exec ./plumbing/fetch_credential secret_key) \
		--entrypoint=/push-to-s3 \
		bioboxes/file-deployer \
		nucleotides-tools client $(version) /$(dir $<)/nucleotides-client.tar.gz

build: $(dist) test-build

test-build: $(dist) .installer_image
	@docker run \
		--tty \
		--volume=$(abspath $(dir $<)):/dist:ro \
		$(installer-image) \
		/bin/bash -c "pip install --user /$< && clear && /root/.local/bin/nucleotides -h"

ssh: $(dist)
	@docker run \
		--interactive \
		--tty \
		--volume=$(abspath $(dir $^)):/dist:ro \
		$(installer-image) \
		/bin/bash

$(dist): $(shell find bin nucleotides) requirements.txt setup.py MANIFEST.in
	@$(path) python setup.py sdist
	@touch $@

#################################################
#
# Run tests and features
#
#################################################

test = $(params) $(path) nosetests --rednose

feature: Gemfile.lock $(credentials)
	@$(params) $(path) bundle exec cucumber $(ARGS)

test:
	@$(test)

autotest:
	@clear && $(test) -a '!slow' || true # Using true starts tests even on failure
	@fswatch -o ./nucleotides -o ./test | xargs -n 1 -I {} bash -c "clear && $(test) -a '!slow'"

################################################
#
# Bootstrap required project resources
#
################################################

bootstrap: \
	Gemfile.lock \
	vendor/python \
	.api_container \
	.installer_image \
	.depoy_image \
	tmp/data/reads.fq.gz \
	tmp/data/dummy.reads.fq.gz \
	tmp/data/reference.fa \
	tmp/data/assembly_metrics.tsv \
	tmp/data/contigs.fa \
	tmp/data/container_runtime.json \
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

tmp/data/nucleotides:
	mkdir -p $(dir $@)
	git clone https://github.com/nucleotides/nucleotides-data.git $@
	cd ./$@ && git reset --hard bb895e1
	rm $@/inputs/data/*
	cp data/test_organism.yml $@/inputs/data/
	cp data/benchmark.yml $@/inputs/

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

.installer_image: $(shell find images/test-install -type f)
	cd ./images/$(installer-image) && docker build --tag $(installer-image) .
	touch $@

.depoy_image:
	docker pull bioboxes/file-deployer

vendor/python: requirements/default.txt requirements/development.txt
	@mkdir -p log
	@virtualenv $@ 2>&1 > log/virtualenv.txt
	@$(path) pip install \
		--requirement requirements/default.txt \
		--requirement requirements/development.txt \
		2>&1 > log/pip.txt
	@touch $@


Gemfile.lock: Gemfile
	mkdir -p log
	bundle install --path vendor/bundle 2>&1 > log/bundle.txt

clean:
	docker kill $(shell cat .rdm_container); true
	docker kill $(shell cat .api_container); true
	rm -f .*_container .*_image Gemfile.lock
	rm -rf vendor

.PHONY: test autotest bootstrap
