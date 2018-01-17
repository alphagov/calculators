source 'https://rubygems.org'

ruby File.read(".ruby-version").chomp

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.2'

if ENV['SLIMMER_DEV']
  gem 'slimmer', path: '../slimmer'
else
  gem 'slimmer', '~> 11.1.1'
end
gem 'plek', '~> 2.0.0'

gem 'gds-api-adapters', '~> 51.0.0'
gem 'govuk_frontend_toolkit', '~> 7.2.0'
gem 'govuk-content-schema-test-helpers', '~> 1.6.0'
gem 'govuk_navigation_helpers', '~> 7.3'
gem 'sass-rails', '5.0.7'
gem 'govuk_elements_rails', '~> 3.1.2'

gem 'rack_strip_client_ip', '0.0.2'
gem 'nokogiri'

gem 'uglifier', '~> 4.1'

group :development do
  gem 'better_errors', '~>2.1'
  gem 'binding_of_caller', '~>0.7'
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'timecop', '~> 0.9.1'
  gem 'govuk-lint', '3.6.0'
  gem 'pry-byebug'
  gem 'listen', '~> 3.1.5'
  gem 'rspec-rails', '~> 3.6.0'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'poltergeist'
  gem 'capybara', '~> 2.17.0'
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'simplecov-rcov', '0.2.3', require: false
  gem 'ci_reporter_rspec', '~> 1.0.0'
  gem 'webmock', '~> 3.1.1', require: false
end

# Upgrade to Sentry
gem "govuk_app_config", "~> 1.1.0"
