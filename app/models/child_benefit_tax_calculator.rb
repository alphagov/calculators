require 'active_model'

class ChildBenefitTaxCalculator
  include ActiveModel::Validations

  attr_reader :adjusted_net_income_calculator, :adjusted_net_income, :children_count,
    :starting_children, :tax_year

  NET_INCOME_THRESHOLD = 50000
  TAX_COMMENCEMENT_DATE = Date.parse('7 Jan 2013')

  TAX_YEARS = {
    "2012" => [Date.parse("2012-04-06"), Date.parse("2013-04-05")],
    "2013" => [Date.parse("2013-04-06"), Date.parse("2014-04-05")],
    "2014" => [Date.parse("2014-04-06"), Date.parse("2015-04-05")],
    "2015" => [Date.parse("2015-04-06"), Date.parse("2016-04-05")],
  }

  validate :valid_child_dates
  validates_inclusion_of :tax_year, in: TAX_YEARS.keys.map(&:to_i), message: "select a tax year"
  validate :tax_year_contains_at_least_one_child

  def initialize(params = {})
    @adjusted_net_income_calculator = AdjustedNetIncomeCalculator.new(params)
    @adjusted_net_income = calculate_adjusted_net_income(params[:adjusted_net_income])
    @children_count = params[:children_count] ? params[:children_count].to_i : 1
    @starting_children = process_starting_children(params[:starting_children])
    @tax_year = params[:year].to_i
  end

  def self.valid_date_params?(params)
    params && params[:year].present? && params[:month].present? && params[:day].present?
  end

  def valid_date_params?(params)
    self.class.valid_date_params?(params)
  end

  def monday_on_or_after(date)
    date + ((1 - date.wday) % 7)
  end

  def nothing_owed?
    @adjusted_net_income < NET_INCOME_THRESHOLD || tax_estimate.abs == 0
  end

  def has_errors?
    errors.any? || starting_children.select { |c| c.errors.any? }.any?
  end

  def percent_tax_charge
    if @adjusted_net_income >= 60000
      100
    elsif (59900..59999).cover?(@adjusted_net_income)
      99
    else
      ((@adjusted_net_income - 50000) / 100.0).floor
    end
  end

  def child_benefit_start_date
    @tax_year == 2012 ? TAX_COMMENCEMENT_DATE : selected_tax_year.first
  end

  def child_benefit_end_date
    selected_tax_year.last
  end

  def can_calculate?
    valid? && !has_errors? && @starting_children.any?
  end

  def selected_tax_year
    TAX_YEARS[@tax_year.to_s]
  end

  def can_estimate?
    @total_annual_income > 0 && can_calculate?
  end

  def benefits_claimed_amount
    all_weeks_children = {}
    (child_benefit_start_date...child_benefit_end_date).each_slice(7) do |week|
      monday = monday_on_or_after(week.first)
      all_weeks_children[monday] = 0
      @starting_children.each do |child|
        all_weeks_children[monday] += 1 if eligible?(child, tax_year, monday)
      end
    end
    # calculate total for all weeks
    total = all_weeks_children.values.inject(0) do |sum, n|
      sum + BigDecimal.new(weekly_sum_for_children(n).to_s)
    end
    total.to_f
  end

  def tax_estimate
    (benefits_claimed_amount * (percent_tax_charge / 100.0)).floor
  end

private

  def process_starting_children(children)
    [].tap do |ary|
      @children_count.times do |n|
        if children && children[n.to_s] && valid_date_params?(children[n.to_s][:start])
          ary << StartingChild.new(children[n.to_s])
        else
          ary << StartingChild.new
        end
      end
    end
  end

  def eligible?(child, tax_year, week_start_date)
    eligible_for_tax_year?(child, tax_year) &&
      days_include_week?(child.adjusted_start_date, child.benefits_end, week_start_date)
  end

  def eligible_for_tax_year?(child, tax_year)
    if tax_year == 2012
      !(Date.parse('1 April 2013')..Date.parse('5 April 2013')).cover?(child.start_date)
    else
      !(Date.parse("31 March #{tax_year + 1}")..Date.parse("5 April #{tax_year + 1}")).cover?(child.start_date)
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
    rate = ChildBenefitRates.new(tax_year)
    if num_children > 0
      rate.first_child_rate + (num_children - 1) * rate.additional_child_rate
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
    ((end_date - start_date) / 7).floor
  end

  def calculate_adjusted_net_income(adjusted_net_income)
    if @adjusted_net_income_calculator.can_calculate?
      @adjusted_net_income_calculator.calculate_adjusted_net_income
    elsif adjusted_net_income.present?
      adjusted_net_income.gsub(/[£, -]/, '').to_i
    end
  end

  def parse_child_date(date)
    Date.new(date[:year].to_i, date[:month].to_i, date[:day].to_i)
  end

  def valid_child_dates
    @starting_children.each(&:valid?)
  end

  def tax_year_contains_at_least_one_child
    return unless selected_tax_year.present? && @starting_children.select(&:valid?).any?

    in_tax_year = @starting_children.reject { |c| c.start_date.nil? || c.start_date > selected_tax_year.last || (c.end_date.present? && c.end_date < selected_tax_year.first) }
    if in_tax_year.empty?
      @starting_children.first.errors.add(:end_date, "You haven't received any Child Benefit for the tax year selected. Check your Child Benefit dates or choose a different tax year.")
    end
  end
end
