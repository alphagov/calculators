# encoding: utf-8
module ChildBenefitTaxHelper
  def money_input(name, amount)
    text_field_tag(name, number_to_currency((amount > 0 ? amount : nil), unit: "£", precision: 2), :placeholder => "£")
  end

  def tax_year_label(years)
    "#{years.first.year} to #{years.last.year}"
  end
end
