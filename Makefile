path := PATH=./vendor/python/bin:$(shell echo "${PATH}")

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

#################################################
#
# Run tests and features
#
#################################################

test = $(params) $(path) nosetests --rednose

feature: Gemfile.lock $(credentials)
	@$(params) bundle exec cucumber $(ARGS)

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

bootstrap: Gemfile.lock vendor/python .api_container tmp/data/reads.fq.gz tmp/data/dummy.reads.fq.gz

tmp/data/reads.fq.gz: ./plumbing/fetch_s3_file
	$(shell mkdir -p $(dir $@))
	bundle exec $^ s3://nucleotides-testing/short-read-assembler/reads.fq.gz $@

tmp/data/dummy.reads.fq.gz: ./plumbing/fetch_s3_file
	$(shell mkdir -p $(dir $@))
	bundle exec $^ s3://nucleotides-testing/short-read-assembler/dummy.reads.fq.gz $@

tmp/data/fixtures.sql: tmp/data/nucleotides .rdm_container
	docker run \
	  --env="$(db_user)" \
	  --env="$(db_pass)" \
	  --env="$(db_name)" \
	  --env=POSTGRES_HOST=//localhost:5433 \
          --volume=$(abspath $</data):/data:ro \
	  nucleotides/api:staging \
	  migrate
	PGPASSWORD=pass pg_dump -d postgres -h $(docker_host) -U postgres -p 5433 --inserts > $@

tmp/data/nucleotides:
	git clone git@github.com:nucleotides/nucleotides-data.git $@
	cd ./$@ && git checkout feature/new-nucleotides-api

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
		kiasaki/alpine-postgres:9.4 \
		> $@
	sleep 3

.rdm_image:
	docker pull kiasaki/alpine-postgres:9.4
	touch $@

.api_image:
	docker pull nucleotides/api:staging
	touch $@

vendor/python: requirements.txt
	mkdir -p log
	virtualenv $@ 2>&1 > log/virtualenv.txt
	$(path) pip install -r $< 2>&1 > log/pip.txt
	touch $@

Gemfile.lock: Gemfile
	mkdir -p log
	bundle install --path vendor/bundle 2>&1 > log/bundle.txt

.PHONY: test autotest bootstrap
