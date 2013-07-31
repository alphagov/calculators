require 'gds_api/helpers'
require 'gds_api/content_api'

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include GdsApi::Helpers
  include Slimmer::Headers

  def set_slimmer_artefact_headers(artefact, slimmer_headers={})
    slimmer_headers[:format] ||= artefact["format"]
    set_slimmer_headers(slimmer_headers)
    set_slimmer_artefact(artefact)
  end

  def fetch_artefact(slug)
    artefact = content_api.artefact(slug)
    raise RecordNotFound unless artefact
    artefact
  rescue URI::InvalidURIError
     raise RecordNotFound
  end
end
