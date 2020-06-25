source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

gem "rails", "~> 5.2.4"

gem "gds-api-adapters", "~> 63.6.0"
gem "govuk-content-schema-test-helpers", "~> 1.6.1"
gem "govuk_app_config", "~> 2.2.0"
gem "govuk_publishing_components", "~> 21.50.1"
gem "nokogiri"
gem "plek", "~> 3.0.0"
gem "rack_strip_client_ip", "0.0.2"
gem "sass-rails", "5.0.7"
gem "slimmer", "~> 14.0.0"
gem "uglifier", "~> 4.2"

group :development do
  gem "better_errors", "~>2.7"
  gem "binding_of_caller", "~>0.8"
  gem "web-console", ">= 3.3.0"
end

group :development, :test do
  gem "listen", "~> 3.2.1"
  gem "pry-byebug"
  gem "rspec-rails", "~> 4.0.1"
  gem "rubocop-govuk"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "timecop", "~> 0.9.1"
end

group :test do
  gem "ci_reporter_rspec", "~> 1.0.0"
  gem "govuk_test"
  gem "launchy"
  gem "rails-controller-testing", "~> 1.0.4"
  gem "simplecov", require: false
  gem "webmock", "~> 3.8.3", require: false

  gem "ci_reporter"
  gem "minitest", "~> 5.14"
  gem "minitest-focus", "~> 1.2"
  gem "mocha", "1.11.2", require: false
  gem "shoulda", "~> 3.6.0"
  gem "simplecov-rcov", "~> 0.2.3", require: false
end
