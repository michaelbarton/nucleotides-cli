feature: Gemfile.lock $(credentials)
	bundle exec cucumber $(ARGS)

test: Gemfile.lock
	bundle exec rspec

autotest: Gemfile.lock
	bundle exec autotest

################################################
#
# Bootstrap required project resources
#
################################################

bootstrap: Gemfile.lock .api_container

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

Gemfile.lock: Gemfile
	bundle install --path vendor/bundle
