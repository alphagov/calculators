# encoding: utf-8
module ApplicationHelper
  def last_updated_date
    File.mtime( Rails.root.join('REVISION') ).to_date rescue Date.today
  end

  def step(num, text)
    "<h2><span class='steps' id='step-#{num}'><span class='visuallyhidden'>Step #{num}</span></span>#{text}</h2>".html_safe
  end

  def internal_url(path)
    PRIVATE_FRONTEND_INTERNAL_LINKS ? "#{Plek.current.find('private-frontend')}#{path}?edition=1" : "#{path}"
  end

end
