# encoding: utf-8
module ApplicationHelper
  def last_updated_date
    File.mtime(Rails.root.join('REVISION')).to_date rescue Date.today
  end

  def step(num, text, description = nil)
    text << "<span id='step-#{num}-description'>#{description}</span>" if description.present?
    "<div class=\"govuk-govspeak\"><ul class=\"steps\"><li class=\"steps-step#{num}\"><h2>#{text}</h2></li></ul></div>".html_safe
  end
end
