class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include Slimmer::Template
  slimmer_template "core_layout"

  if ENV["BASIC_AUTH_USERNAME"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD"),
    )
  end
end
