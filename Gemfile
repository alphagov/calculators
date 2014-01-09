source 'https://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rails', '3.2.16'

gem 'unicorn', '4.6.2'

gem 'exception_notification', '3.0.1'
gem 'aws-ses', '0.5.0', :require => 'aws/ses'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '3.20.0'
end
gem 'plek', '1.3.1'

gem 'gds-api-adapters', '8.2.1'
gem 'govuk_frontend_toolkit', '0.20.0'
gem 'sass-rails', '3.2.5'

gem 'logstasher', '0.4.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails', '2.13.2'
  gem 'capybara', '2.1.0'
  gem 'simplecov-rcov', '0.2.3', :require => false
  gem 'ci_reporter', '1.8.4'
  gem 'webmock', :require => false
  gem 'timecop', '0.6.2.2'
  gem 'poltergeist', '1.3.0'
end
