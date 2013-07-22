class ChildBenefitTaxCalculator
  attr_reader :adjusted_net_income, :starting_children, :stopping_children, :tax_year

  NET_INCOME_THRESHOLD = 50000

  FIRST_CHILD_RATE = 20.3
  FURTHER_CHILD_RATE = 13.4

  TAX_YEARS = {
    "2012" => [Date.parse("2012-04-06"), Date.parse("2013-04-05")],
    "2013" => [Date.parse("2013-04-06"), Date.parse("2014-04-05")],
  }

  def initialize(params = {})
    @total_annual_income = to_integer(params[:total_annual_income])
    @gross_pension_contributions = to_integer(params[:gross_pension_contributions])
    @net_pension_contributions = to_integer(params[:net_pension_contributions])
    @trading_losses_self_employed = to_integer(params[:trading_losses_self_employed])
    @gift_aid_donations = to_integer(params[:gift_aid_donations])
    @adjusted_net_income = calculate_adjusted_income(to_integer(params[:adjusted_net_income]))
    @starting_children = process_starting_children(params[:starting_children])
    @tax_year = params[:year].to_i
  end


  def owed
    if @starting_children.empty?
      benefits_no_starting_stopping_children
    else
      benefits_with_changing_children
    end
  end

  def nothing_owed?
    @adjusted_net_income < NET_INCOME_THRESHOLD or amount_owed == 0
  end

  def amount_owed
    owed[:benefit_owed_amount].abs
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

  def child_benefit_start_date
    @tax_year == 2012 ? Date.parse('7 Jan 2013') : TAX_YEARS[@tax_year.to_s].first
  end

  def child_benefit_end_date
    TAX_YEARS[@tax_year.to_s].last
  end

  def can_calculate?
    TAX_YEARS.keys.map(&:to_i).include?(@tax_year) and !@starting_children.empty?
  end

  def can_estimate?
    @total_annual_income > 0 and can_calculate?
  end

  def benefits_claimed_amount
    all_weeks_children = {}
    (child_benefit_start_date...child_benefit_end_date).each_slice(7) do |week|
      all_weeks_children[week.first] = 0
      @starting_children.each do |child|
        if days_include_week?(child.start_date, child.benefits_end, week.first)
          all_weeks_children[week.first] += 1
        end
      end
    end
    
    # calculate total for all weeks
    all_weeks_children.values.inject(0) do |sum, n|
      sum + weekly_sum_for_children(n)
    end
  end

  # TODO: Is this an appropriate name for this method?
  #
  def taxable_amount
    benefits_claimed_amount * (percent_tax_charge / 100.0)
  end

  private

  def process_starting_children(children)
    if children
      children.map{ |c| StartingChild.new(c) }
    else
      [StartingChild.new]
    end
  end

  def days_include_week?(start_date, end_date, week_start_date)
    if start_date.nil?
      end_date >= week_start_date
    elsif end_date.nil?
      start_date <= week_start_date
    else
      (start_date..end_date).cover?(week_start_date)
    end
  end

  # TODO: This method will be replaced by more atomic calculations.
  #
  def benefits_with_changing_children
    all_weeks_children = {}
    (child_benefit_start_date..child_benefit_end_date).each_slice(7) do |week|
      all_weeks_children[week.first] = 0
      @starting_children.each do |child|
        if days_include_week?(child.start_date, child.benefits_end, week.first)
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


  def benefit_taxable_weeks(start_date, end_date)
    (( end_date - start_date ) / 7).floor
  end

  def parse_child_date(date)
    Date.new(date[:year].to_i, date[:month].to_i, date[:day].to_i)
  end


  def calculate_adjusted_income(adjusted_income)
    if adjusted_income == 0
      @total_annual_income - @gross_pension_contributions - (
        @net_pension_contributions * 1.25
      ) - @trading_losses_self_employed - (@gift_aid_donations * 1.25)
    else
      adjusted_income
    end
  end

  def to_integer(val)
    val.gsub!(/\D/,'') if val.is_a?(String)
    val.to_i
  end
end

class StartingChild
  attr_reader :start_date, :end_date
  def initialize(params = {})
    if has_date_params?(params, :start)
      @start_date = Date.new(params[:start][:year].to_i,
                             params[:start][:month].to_i,
                             params[:start][:day].to_i)
    end
    if has_date_params?(params, :stop) 
      @end_date = Date.new(params[:stop][:year].to_i,
                           params[:stop][:month].to_i,
                           params[:stop][:day].to_i)
    end
  end

  def benefits_end
    tax_years = ChildBenefitTaxCalculator::TAX_YEARS
    @end_date ? @end_date : tax_years[tax_years.keys.sort.last].last
  end

  private

  def has_date_params?(params, date_sym)
    params[date_sym] and params[date_sym][:year].present? and
      params[date_sym][:month].present? and params[date_sym][:day].present?
  end
end
