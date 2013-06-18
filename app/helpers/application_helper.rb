# encoding: utf-8
module ApplicationHelper

  def step(num, text)
    "<h2><span class='steps' id='step-#{num}'><span class='visuallyhidden'>Step #{num}</span></span>#{text}</h2>".html_safe
  end

  def number_input(label, name, placeholder="")
    label = label_tag(name, label)
    input = text_field_tag(name, params[name.to_sym], { :placeholder => placeholder })
    para_group(label + input)
  end

  def para_group(inner)
    "<p class='group number-input'>#{inner}</p>".html_safe
  end

end
