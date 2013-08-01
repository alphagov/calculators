# encoding: utf-8
module ChildBenefitTaxHelper
  def money_input(name, amount)
    text_field_tag(name, number_to_currency((amount > 0 ? amount : nil), unit: "£", precision: 2), :placeholder => "£")
  end

  def tax_year_label(dates)
    "#{dates.first.year} to #{dates.last.year}"
  end
end
