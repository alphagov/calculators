# encoding: utf-8
module ApplicationHelper
  def step(num, text)
    "<h2 class=\"step step-#{num}\">#{text}</h2>".html_safe
  end
end
