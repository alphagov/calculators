class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include Slimmer::Template
  include Slimmer::GovukComponents
  slimmer_template 'core_layout'
end
