class ChildBenefitTaxCalculator
  attr_reader :adjusted_net_income, :children_count, :starting_children, :stopping_children, :tax_year

  FIRST_CHILD_RATE = 20.3
  FURTHER_CHILD_RATE = 13.4

  TAX_YEARS = {
    "2012" => [Date.parse("2012-04-06"), Date.parse("2013-04-05")],
    "2013" => [Date.parse("2013-04-06"), Date.parse("2014-04-05")]
  }

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
    if @starting_children.empty? && @stopping_children.empty?
      benefits_no_starting_stopping_children
    else
      benefits_with_changing_children
    end
  end

  def amount_owed
    owed[:benefit_owed_amount].abs
  end

  private

  def benefits_no_starting_stopping_children
    # benefit rates fixed until April 2014: gov.uk/child-benefit-rates
    # 20.30 for 1st child, 13.40 for each next child
    benefit_weekly_amount = 0

    @children_count.times do |child_number|
      benefit_weekly_amount += ( child_number == 0 ? FIRST_CHILD_RATE : FURTHER_CHILD_RATE )
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

  def benefits_with_changing_children
    all_weeks_children = {}
    (child_benefit_start_date..child_benefit_end_date).each_slice(7) do |week|
      all_weeks_children[week.first] = 0
      @starting_children.each do |date|
        child_start = parse_child_date(date)
        if child_start <= week.first
          all_weeks_children[week.first] += 1
        end
      end

      @stopping_children.each do |date|
        child_end = parse_child_date(date)
        if child_end >= week.first
          all_weeks_children[week.first] += 1
        end
      end
    end

    # calculate taxable total for all weeks
    all_weeks_sum = all_weeks_children.values.inject(0) do |sum, n|
      sum + weekly_sum_for_children(n)
    end

    if @tax_year == 2012
      # only taxable from 7/01/2013
      taxed_weeks_children = all_weeks_children.select do |key, val|
        (Date.parse("2013-01-07")..child_benefit_end_date).cover?(key)
      end
      taxed_weeks_sum = taxed_weeks_children.values.inject(0) do |sum, n|
        sum + weekly_sum_for_children(n)
      end
    else
      # taxing the entire year
      taxed_weeks_children = all_weeks_children
      taxed_weeks_sum = all_weeks_sum
    end

    {
      :benefit_taxable_amount => taxed_weeks_sum,
      :benefit_taxable_weeks => taxed_weeks_children.length,
      :benefit_claimed_amount => all_weeks_sum,
      :benefit_claimed_weeks => 52,
      :benefit_owed_amount =>taxed_weeks_sum * (percent_tax_charge / 100.0)
    }
  end

  def weekly_sum_for_children(num_children)
    if num_children > 0
      FIRST_CHILD_RATE + (num_children - 1 ) * FURTHER_CHILD_RATE
    else
      0
    end
  end

  def taxable_weeks
    if @tax_year == 2012
      # special case for 2012-13, only weeks from 7th Jan 2013 are taxable
      benefit_taxable_weeks(Date.parse("2013-01-07"), child_benefit_end_date)
    else
      benefit_taxable_weeks(child_benefit_start_date, child_benefit_end_date)
    end
  end

  def percent_tax_charge
    if @adjusted_net_income >= 60001
      100
    elsif (59900..60000).cover?(@adjusted_net_income)
      99
    else
      ((@adjusted_net_income - 50000)/100.0).floor
    end
  end

  def benefit_taxable_weeks(start_date, end_date)
    (( end_date - start_date ) / 7).floor
  end

  def parse_child_date(date)
    Date.new(date[:year].to_i, date[:month].to_i, date[:day].to_i)
  end

  def child_benefit_start_date
    TAX_YEARS[@tax_year.to_s].first
  end

  def child_benefit_end_date
    TAX_YEARS[@tax_year.to_s].last
  end

  def calculate_adjusted_income(adjusted_income)
    if adjusted_income == 0
      @total_annual_income - @gross_pension_contributions - (@net_pension_contributions * 1.25) - @trading_losses_self_employed - (@gift_aid_donations * 1.25)
    else
      adjusted_income
    end
  end
end
