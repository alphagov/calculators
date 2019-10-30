# encoding: utf-8

module ApplicationHelper
  def step(num, text)
    "<span class=\"step step-#{num}\">#{text}</span>".html_safe
  end

  def current_path_without_query_string
    request.original_fullpath.split("?", 2).first
  end

  def children_select_options
    Array(1..10).map do |num|
      {
        text: num,
        value: num,
        selected: num == @calculator.children_count ? true : false
      }
    end
  end

  def tax_year_radio_options
    ChildBenefitTaxCalculator::TAX_YEARS.keys.map do |year|
      {
        value: year,
        text: "#{year} to #{year.to_i + 1}",
        checked: @calculator.tax_year == year.to_i
      }
    end
  end
end
