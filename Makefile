credentials = .aws_credentials
fetch_cred  = $$(./script/get_credential $(credentials) $(1))

bootstrap: Gemfile.lock $(credentials)

feature: Gemfile.lock $(credentials)
	AWS_ACCESS_KEY=$(call fetch_cred,AWS_ACCESS_KEY) \
	AWS_SECRET_KEY=$(call fetch_cred,AWS_SECRET_KEY) \
	bundle exec cucumber $(ARGS)

test: Gemfile.lock
	bundle exec rspec 

autotest: Gemfile.lock
	bundle exec autotest

Gemfile.lock: Gemfile
	bundle install --path vendor/bundle

$(credentials): ./script/create_aws_credentials
	$< $@
