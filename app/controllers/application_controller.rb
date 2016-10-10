class ApplicationController < ActionController::Base
  protect_from_forgery

  include Slimmer::Template
  include Slimmer::SharedTemplates

  slimmer_template 'wrapper'
end
