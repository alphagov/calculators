# encoding: UTF-8
class AdjustedNetIncomeCalculator
  
  PARAM_KEYS = [:gross_income, :other_income, :pension_contributions_from_pay,
    :retirement_annuities, :cycle_scheme, :childcare, :pensions, :property,
    :non_employment_income, :gift_aid_donations, :outgoing_pension_contributions]

  def initialize(params)
    PARAM_KEYS.each do |key|
      instance_variable_set :"@#{key}", integer_value(params[key])
    end
  end

  def adjusted_net_income
    (@gross_income + @other_income + @pensions + @property + @non_employment_income) - deductions
  end

  private

  def deductions
    grossed_up(@pension_contributions_from_pay) + grossed_up(@gift_aid_donations) + 
      @retirement_annuities + @cycle_scheme + @childcare
  end

  def grossed_up(amount)
    (amount * 1.25)
  end

  def integer_value(val)
    val.gsub!(/[£,-]/,'') if val.is_a?(String)
    val.to_i
  end
end
