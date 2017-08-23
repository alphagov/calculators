# encoding: utf-8
module ApplicationHelper
  def step(num, text)
    "<h2 class=\"step step-#{num}\">#{text}</h2>".html_safe
  end

  def current_path_without_query_string
    request.original_fullpath.split("?", 2).first
  end
end
