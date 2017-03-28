# encoding: utf-8
module ApplicationHelper
  def last_updated_date
    File.mtime(Rails.root.join('REVISION')).to_date rescue Date.today
  end

  def step(num, text, description = nil)
    text << " <span id='step-#{num}-description'>#{description}</span>" if description.present?
    "<h2><span class='steps' id='step-#{num}'><span class='visuallyhidden'>Step #{num}</span></span>#{text}</h2>".html_safe
  end
end
