source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'unicorn', '4.6.2'

gem 'exception_notification', '3.0.1'
gem 'aws-ses', '0.5.0', :require => 'aws/ses'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '3.16.0'
end
gem 'plek', '1.3.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails', '2.13.2'
  gem 'capybara', '2.0.3' # 2.1.0 doesn't work on ruby 1.9.2
  gem 'simplecov-rcov', '0.2.3', :require => false
  gem 'ci_reporter', '1.8.4'
end
