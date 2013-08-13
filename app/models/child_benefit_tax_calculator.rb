# encoding: UTF-8
class ChildBenefitTaxCalculator

  include ActiveModel::Validations

  attr_reader :adjusted_net_income_calculator, :adjusted_net_income, :children_count,
    :starting_children, :tax_year

  NET_INCOME_THRESHOLD = 50000

  FIRST_CHILD_RATE = 20.3
  FURTHER_CHILD_RATE = 13.4

  TAX_YEARS = {
    "2012" => [Date.parse("2012-04-06"), Date.parse("2013-04-05")],
    "2013" => [Date.parse("2013-04-06"), Date.parse("2014-04-05")],
  }

  validate :valid_child_dates
  validates_inclusion_of :tax_year, :in => TAX_YEARS.keys.map(&:to_i), :message => "Select a tax year"

  def initialize(params = {})
    @adjusted_net_income_calculator = AdjustedNetIncomeCalculator.new(params)
    @adjusted_net_income = calculate_adjusted_net_income(params[:adjusted_net_income])
    @children_count = params[:children_count] ? params[:children_count].to_i : 1
    @starting_children = process_starting_children(params[:starting_children])
    @tax_year = params[:year].to_i
  end

  def self.valid_date_params?(params)
    params and params[:year].present? and params[:month].present? and params[:day].present?
  end

  def valid_date_params?(params)
    self.class.valid_date_params?(params)
  end

  def nothing_owed?
    @adjusted_net_income < NET_INCOME_THRESHOLD or tax_estimate.abs == 0
  end
  
  def has_errors?
    errors.any? or starting_children.select{|c| c.errors.any? }.any?
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

  def tax_estimate
    (benefits_claimed_amount * (percent_tax_charge / 100.0)).floor
  end
  
  private

  def process_starting_children(children)
    [].tap do |ary|
      @children_count.times do |n|
        if children and children[n.to_s] and valid_date_params?(children[n.to_s][:start])
          ary << StartingChild.new(children[n.to_s])
        else
          ary << StartingChild.new
        end
      end
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

  def calculate_adjusted_net_income(adjusted_net_income)
    if @adjusted_net_income_calculator.can_calculate?
      @adjusted_net_income_calculator.calculate_adjusted_net_income
    elsif adjusted_net_income.present?
      adjusted_net_income.gsub(/[£, -]/,'').to_i
    end
  end

  def parse_child_date(date)
    Date.new(date[:year].to_i, date[:month].to_i, date[:day].to_i)
  end

  def valid_child_dates
    @starting_children.each { |c| c.valid? }
  end
end
