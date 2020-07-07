require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Calculators
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Enable the asset pipeline
    config.assets.enabled = true

    config.assets.precompile += %w[
      application.css
      application-ie6.css
      application-ie7.css
      application-ie8.css
      print.css
      test-dependencies.js
    ]

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = "1.0"
    config.assets.prefix = "/assets/calculators"

    # allow overriding the asset host with an enironment variable, useful for
    # when router is proxying to this app but asset proxying isn't set up.
    config.asset_host = ENV["ASSET_HOST"]

    # Disable Rack::Cache
    config.action_dispatch.rack_cache = nil

    # Override Rails 4 default which restricts framing to SAMEORIGIN.
    config.action_dispatch.default_headers = {
      "X-Frame-Options" => "ALLOWALL",
    }

    config.eager_load_paths << Rails.root.join("lib")

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
