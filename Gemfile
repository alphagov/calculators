source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

gem "rails", "~> 6.0.3"

gem "gds-api-adapters", "~> 67.0.1"
gem "govuk_app_config", "~> 2.7.1"
gem "govuk-content-schema-test-helpers", "~> 1.6.1"
gem "govuk_publishing_components", "~> 23.7.3"
gem "nokogiri"
gem "plek", "~> 4.0.0"
gem "rack_strip_client_ip", "0.0.2"
gem "sass-rails", "5.1.0"
gem "slimmer", "~> 15.3.0"
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
  gem "rails-controller-testing", "~> 1.0.5"
  gem "simplecov", require: false
  gem "webmock", "~> 3.8.3", require: false
end
