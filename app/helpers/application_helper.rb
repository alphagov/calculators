# encoding: utf-8
module ApplicationHelper

  def step(num, text)
    "<h2><span class='steps' id='step-#{num}'><span class='visuallyhidden'>Step </span>#{num} </span>#{text}</h2>".html_safe
  end

  def money_input(label, name)
    label = label_tag(name, label)
    input = text_field_tag(name, params[name.to_sym], { :placeholder => "£" })
    para_group(label + input)
  end

  def para_group(inner)
    "<p class='group'>#{inner}</p>".html_safe
  end

end
