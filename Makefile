bootstrap: Gemfile.lock

feature: Gemfile.lock
	bundle exec cucumber $(ARGS)

Gemfile.lock: Gemfile
	bundle install --path vendor/bundle
