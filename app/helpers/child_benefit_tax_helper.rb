module ChildBenefitTaxHelper
  def money_input_value(amount)
    number_to_currency((amount.blank? || amount <= 0 ? nil : amount), unit: "£", precision: 2)
  end

  def tax_year_label(year)
    dates = ChildBenefitTaxCalculator.tax_years[year.to_s]
    "#{dates.first.year} to #{dates.last.year}"
  end

  def can_haz_results?(calculator)
    params[:results] && calculator.can_calculate?
  end

  def sa_register_deadline(calculator)
    end_date = ChildBenefitTaxCalculator.tax_years[calculator.tax_year.to_s].last
    "5 October #{end_date.year}"
  end

  def tax_year_incomplete?(calculator)
    end_date = ChildBenefitTaxCalculator.tax_years[calculator.tax_year.to_s].last
    end_date >= Time.zone.today
  end
end
