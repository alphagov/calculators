require 'gds_api/helpers'
require 'slimmer/headers'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include GdsApi::Helpers
  include Slimmer::Template
  include Slimmer::Headers

  slimmer_template 'wrapper'

  protected

  def set_slimmer_artefact_headers(artefact)
    set_slimmer_headers(format: "calculator")
    set_slimmer_artefact(artefact)
  end
end
