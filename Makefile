docker_host := $(shell echo ${DOCKER_HOST} | egrep -o "\d+.\d+.\d+.\d+")

ifndef DOCKER_HOST
	docker_host := http://localhost
else
	docker_host := http://$(shell echo ${DOCKER_HOST} | egrep -o "\d+.\d+.\d+.\d+")
endif


feature: Gemfile.lock $(credentials)
	DOCKER_HOST=$(docker_host) bundle exec cucumber $(ARGS)

test:
	DOCKER_HOST=$(docker_host)

autotest:
	DOCKER_HOST=$(docker_host)

################################################
#
# Bootstrap required project resources
#
################################################

bootstrap: Gemfile.lock vendor/python .api_container

.api_container: .rdm_container .api_image
	docker run \
		--detach=true \
		--env=POSTGRES_USER=postgres \
		--env=POSTGRES_PASSWORD=pass \
		--env=POSTGRES_NAME=postgres \
		--env=POSTGRES_HOST=//localhost:5433 \
		--net=host \
		--publish 80:80 \
		--volume=$(realpath test/data):/data:ro \
		nucleotides/api:staging \
		> $@

.rdm_container: .rdm_image
	docker run \
		--env=POSTGRES_USER=postgres \
		--env=POSTGRES_PASSWORD=pass \
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
