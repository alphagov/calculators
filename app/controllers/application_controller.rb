class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  rescue_from GdsApi::HTTPForbidden, with: :error_403

  include Slimmer::Template
  slimmer_template "core_layout"

  if ENV["BASIC_AUTH_USERNAME"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD"),
    )
  end

protected

  def error_403
    render status: :forbidden, plain: "403 forbidden"
  end
end
