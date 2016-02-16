path := PATH=./vendor/python/bin:$(shell echo "${PATH}")

docker_host := $(shell echo ${DOCKER_HOST} | egrep -o "\d+.\d+.\d+.\d+")

ifdef docker_host
       db_host  := POSTGRES_HOST=//$(docker_host):5433
else
       db_host  := POSTGRES_HOST=//localhost:5433
endif

db_user := POSTGRES_USER=postgres
db_pass := POSTGRES_PASSWORD=pass
db_name := POSTGRES_NAME=postgres

params := $(db_user) $(db_pass) $(db_name) $(db_host)

#################################################
#
# Run tests and features
#
#################################################

test = DOCKER_HOST=$(docker_host) $(path) nosetests --rednose

feature: Gemfile.lock $(credentials)
	$(params) bundle exec cucumber $(ARGS)

test:
	$(test)

autotest:
	@clear && $(test) || true # Using true starts tests even on failure
	@fswatch -o ./nucleotides -o ./test | xargs -n 1 -I {} bash -c "clear && $(test)"

################################################
#
# Bootstrap required project resources
#
################################################

bootstrap: Gemfile.lock vendor/python .api_container

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
		postgres > $@
	sleep 3

.rdm_image:
	docker pull postgres
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
