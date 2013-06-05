class ChildBenefitTaxCalculator
  attr_reader :adjusted_net_income, :children_count, :starting_children, :stopping_children, :tax_year

  def initialize(params)
    @total_annual_income = params[:total_annual_income].to_i
    @gross_pension_contributions = params[:gross_pension_contributions].to_i
    @net_pension_contributions = params[:net_pension_contributions].to_i
    @trading_losses_self_employed = params[:trading_losses_self_employed].to_i
    @gift_aid_donations = params[:gift_aid_donations].to_i

    @adjusted_net_income = calculate_adjusted_income(params[:adjusted_net_income].to_i)

    @starting_children = params[:starting_children] || []
    @stopping_children = params[:stopping_children] || []
    @tax_year = params[:year].to_i
    @children_count = params[:children_count].to_i
  end

  def owed
    benefit_values = if @starting_children.empty? && @stopping_children.empty?
      benefits_no_starting_stopping_children
    else
      benefits_with_changing_children
    end

    benefit_values[:benefit_tax] = percent_tax_charge * benefit_values[:benefit_taxable_amount]
  end



  private


  def percent_tax_charge
    20
  end

  def benefits_no_starting_stopping_children

    child_benefit_start_date = @tax_year == "2012" ? Date.parse("2012-04-06") : Date.parse("2013-04-06")
    child_benefit_end_date = @tax_year == "2012" ? Date.parse("2013-04-05") : Date.parse("2014-04-05")

    # amount they would claim over a year
    benefit_claimed_weeks = ((child_benefit_end_date - child_benefit_start_date) / 52).floor
    benefit_taxable_weeks = ((child_benefit_end_date - Date.parse("2013-01-07")) / 52).floor

    # benefit rates fixed until April 2014: gov.uk/child-benefit-rates
    # 20.30 for 1st child, 13.40 for each next child
    benefit_claimed_amount = 0
    @children_count.times do |child_number|
      benefit_claimed_amount += ( child_number == 0 ? 20.3 : 13.4 )
    end

    {
      :benefit_taxable_amount => (benefit_claimed_amount / 52) * benefit_taxable_weeks,
      :benefit_taxable_weeks => benefit_taxable_weeks,
      :benefit_claimed_amount => benefit_claimed_amount,
      :benefit_claimed_weeks => benefit_claimed_weeks,
    }
  end

  def benefits_with_changing_children
    {
      :benefit_taxable_amount => 0,
      :benefit_taxable_weeks => 0,
      :benefit_claimed_amount => 0,
      :benefit_claimed_weeks => 0,
    }

  end

  def calculate_adjusted_income(adjusted_income)
    if adjusted_income == 0
      @total_annual_income - @gross_pension_contributions - (@net_pension_contributions * 1.25) - @trading_losses_self_employed - (@gift_aid_donations * 1.25)
    else
      adjusted_income
    end
  end

end
