source "https://rubygems.org"

gemspec

gem "bundler-audit", "~> 0.9.3", require: false
# ruby_audit 3.x requires Ruby >= 3.1. Only the CI audit job needs it.
gem "ruby_audit", "~> 3.1", require: false if RUBY_VERSION >= "3.1.0"
gem "simplecov", require: false
gem "coveralls", require: false
