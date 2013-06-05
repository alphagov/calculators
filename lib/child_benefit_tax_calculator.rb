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
    it_values = if @starting_children.empty? && @stopping_children.empty?
      benefits_no_starting_stopping_children
    else
      benefits_with_changing_children
    end
  end

  private

  def percent_tax_charge
    if @adjusted_net_income >= 60001
      100
    elsif @adjusted_net_income >= 59900 && @adjusted_net_income <= 60000
      99
    else
      ((@adjusted_net_income - 50000)/100).floor
    end
  end

  def benefit_taxable_weeks(start_date, end_date)
    (( end_date - start_date ) / 7).floor
  end

  def benefits_no_starting_stopping_children
    # benefit rates fixed until April 2014: gov.uk/child-benefit-rates
    # 20.30 for 1st child, 13.40 for each next child
    benefit_weekly_amount = 0
    @children_count.times do |child_number|
      benefit_weekly_amount += ( child_number == 0 ? 20.3 : 13.4 )
    end

    taxable_weeks = if @tax_year == 2012
        benefit_taxable_weeks(Date.parse("2013-01-07"), child_benefit_end_date)
      else
        benefit_taxable_weeks(child_benefit_start_date, child_benefit_end_date)
    end

    benefit_claimed_amount = benefit_weekly_amount * 52
    benefit_taxable_amount = benefit_weekly_amount * taxable_weeks

    {
      :benefit_taxable_amount => benefit_taxable_amount,
      :benefit_taxable_weeks => taxable_weeks,
      :benefit_claimed_amount => benefit_claimed_amount,
      :benefit_claimed_weeks => 52,
      :benefit_owed_amount => benefit_taxable_amount * (percent_tax_charge / 100.0)
    }
  end


  def child_benefit_start_date
    @tax_year == 2012 ? Date.parse("2012-04-06") : Date.parse("2013-04-06")
  end

  def child_benefit_end_date
    @tax_year == 2012 ? Date.parse("2013-04-05") : Date.parse("2014-04-05")
  end

  def calculate_adjusted_income(adjusted_income)
    if adjusted_income == 0
      @total_annual_income - @gross_pension_contributions - (@net_pension_contributions * 1.25) - @trading_losses_self_employed - (@gift_aid_donations * 1.25)
    else
      adjusted_income
    end
  end
end
