# encoding: utf-8
module ApplicationHelper
  def last_updated_date
    File.mtime(Rails.root.join('REVISION')).to_date rescue Date.today
  end

  def step(num, text)
    "<h2 class=\"step step-#{num}\">#{text}</h2>".html_safe
  end
end
