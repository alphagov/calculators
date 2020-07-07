source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

gem "rails", "~> 6.0.3", ">= 6.0.3.2"

gem "gds-api-adapters"
gem "govuk-content-schema-test-helpers"
gem "govuk_app_config"
gem "govuk_publishing_components"
gem "nokogiri"
gem "plek"
gem "rack_strip_client_ip"
gem "sass-rails"
gem "slimmer"
gem "uglifier"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "web-console"
end

group :development, :test do
  gem "listen"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "spring"
  gem "spring-watcher-listen"
  gem "timecop"
end

group :test do
  gem "ci_reporter_rspec"
  gem "govuk_test"
  gem "launchy"
  gem "rails-controller-testing"
  gem "simplecov", require: false
  gem "webmock", require: false
end
