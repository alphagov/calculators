# encoding: utf-8

module ChildBenefitTaxHelper
  def money_input(name, amount, options = {})
    text_field_tag(name, number_to_currency((amount.blank? || amount <= 0 ? nil : amount), unit: "£", precision: 2), { placeholder: "£" }.merge(options))
  end

  def money_input_value(amount)
    number_to_currency((amount.blank? || amount <= 0 ? nil : amount), unit: "£", precision: 2)
  end

  def tax_year_label(year)
    dates = ChildBenefitTaxCalculator::TAX_YEARS[year.to_s]
    "#{dates.first.year} to #{dates.last.year}"
  end

  def can_haz_results?
    params[:results] && @calculator.can_calculate?
  end

  def tax_payment_deadline
    end_date = ChildBenefitTaxCalculator::TAX_YEARS[@calculator.tax_year.to_s].last
    "31 January #{end_date.year + 1}"
  end

  def sa_register_deadline
    end_date = ChildBenefitTaxCalculator::TAX_YEARS[@calculator.tax_year.to_s].last
    "5 October #{end_date.year}"
  end

  def tax_year_incomplete?
    end_date = ChildBenefitTaxCalculator::TAX_YEARS[@calculator.tax_year.to_s].last
    end_date >= Date.today
  end
end
