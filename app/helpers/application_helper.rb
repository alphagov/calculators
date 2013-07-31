# encoding: utf-8
module ApplicationHelper

  def step(num, text)
    "<h2><span class='steps' id='step-#{num}'><span class='visuallyhidden'>Step #{num}</span></span>#{text}</h2>".html_safe
  end

end
