# encoding: utf-8
module ChildBenefitTaxHelper
  def money_input(name, amount)
    text_field_tag(name, number_to_currency((amount.blank? || amount <= 0 ? nil : amount), unit: "£", precision: 2), :placeholder => "£")
  end

  def tax_year_label(year)
    dates = ChildBenefitTaxCalculator::TAX_YEARS[year.to_s]
    "#{dates.first.year} to #{dates.last.year}"
  end

  def can_haz_results?
    params[:results] and @calculator.can_calculate?
  end
end
