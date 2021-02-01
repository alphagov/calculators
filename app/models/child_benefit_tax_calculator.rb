require "active_model"

class ChildBenefitTaxCalculator
  include ActiveModel::Validations

  attr_reader :adjusted_net_income_calculator,
              :adjusted_net_income,
              :children_count,
              :starting_children,
              :tax_year,
              :is_part_year_claim,
              :part_year_children_count

  NET_INCOME_THRESHOLD = 50_000
  TAX_COMMENCEMENT_DATE = Date.parse("7 Jan 2013") # special case for 2012-13, only weeks from 7th Jan 2013 are taxable

  validate :valid_child_dates
  validates :is_part_year_claim, presence: { message: "select part year tax claim" }
  validates :tax_year, inclusion: { in: ChildBenefitRates::RATES.keys, message: "select a tax year" }
  validate :valid_number_of_children
  validate :tax_year_contains_at_least_one_child

  def initialize(params = {})
    @adjusted_net_income_calculator = AdjustedNetIncomeCalculator.new(params)
    @adjusted_net_income = calculate_adjusted_net_income(params[:adjusted_net_income])
    @children_count = params[:children_count] ? params[:children_count].to_i : 1
    @is_part_year_claim = params[:is_part_year_claim]
    @part_year_children_count = part_year_children_counter(params[:part_year_children_count])
    @tax_year = params[:year].to_i
    @starting_children = process_starting_children(params[:starting_children])
    @child_benefit_rates = ChildBenefitRates.new(@tax_year)
  end

  def part_year_children_counter(count)
    if @is_part_year_claim == "yes"
      return count ? count.to_i : 0
    end

    0
  end

  def self.valid_date_params?(params)
    params && params[:year].present? && params[:month].present? && params[:day].present?
  end

  def valid_date_params?(params)
    self.class.valid_date_params?(params)
  end

  def total_number_of_mondays(child_benefit_start_date, child_benefit_end_date)
    (child_benefit_start_date..child_benefit_end_date).count(&:monday?)
  end

  def nothing_owed?
    @adjusted_net_income < NET_INCOME_THRESHOLD || tax_estimate.abs.zero?
  end

  def has_errors?
    errors.any? || starting_children_errors?
  end

  def starting_children_errors?
    is_part_year_claim == "yes" && starting_children.select { |c| c.errors.any? }.any?
  end

  def percent_tax_charge
    if @adjusted_net_income >= 60_000
      100
    elsif (59_900..59_999).cover?(@adjusted_net_income)
      99
    else
      ((@adjusted_net_income - 50_000) / 100.0).floor
    end
  end

  def child_benefit_start_date
    @tax_year == 2012 ? TAX_COMMENCEMENT_DATE : selected_tax_year.first
  end

  def child_benefit_end_date
    selected_tax_year.last
  end

  def can_calculate?
    valid? && !has_errors?
  end

  def selected_tax_year
    ChildBenefitTaxCalculator.tax_years[@tax_year.to_s]
  end

  def benefits_claimed_amount
    no_of_full_year_children = @children_count - @part_year_children_count
    first_child_calculated = false
    total_benefit_amount = 0

    if no_of_full_year_children.positive?
      no_of_weeks = total_number_of_mondays(child_benefit_start_date, child_benefit_end_date)
      no_of_additional_children = no_of_full_year_children - 1
      total_benefit_amount = first_child_rate_total(no_of_weeks) + additional_child_rate_total(no_of_weeks, no_of_additional_children)
      first_child_calculated = true
    else
      first_child_calculated = false
    end

    if @starting_children.count.positive?
      first_child = 0

      @starting_children.each_with_index do |child, index|
        start_date = if (child.start_date < child_benefit_start_date) || ((@tax_year == 2012) && (child.start_date < TAX_COMMENCEMENT_DATE))
                       child_benefit_start_date
                     else
                       child.start_date
                     end

        end_date = if child.end_date.nil? || (child.end_date > child_benefit_end_date)
                     child_benefit_end_date
                   else
                     child.end_date
                   end

        no_of_weeks = total_number_of_mondays(start_date, end_date)
        total_benefit_amount = if index.equal?(first_child) && (first_child_calculated == false)
                                 total_benefit_amount + first_child_rate_total(no_of_weeks)
                               else
                                 total_benefit_amount + additional_child_rate_total(no_of_weeks, 1)
                               end
      end
    end
    total_benefit_amount.to_f
  end

  def tax_estimate
    (benefits_claimed_amount * (percent_tax_charge / 100.0)).floor
  end

  def self.start_year
    ChildBenefitRates::RATES.keys.min
  end

  def self.end_year
    today = Time.zone.today
    if today.month > 4 || (today.month == 4 && today.day >= 6)
      [1.year.from_now.year, ChildBenefitRates::RATES.keys.max].min
    else
      [today.year, ChildBenefitRates::RATES.keys.max].min
    end
  end

  def self.tax_years
    (start_year..end_year).each_with_object({}) { |year, hash|
      hash[year.to_s] = [Date.new(year, 4, 6), Date.new(year + 1, 4, 5)]
    }.freeze
  end

private

  def process_starting_children(children)
    number_of_children = if selected_tax_year.present? || @is_part_year_claim == "yes"
                           @part_year_children_count
                         else
                           @children_count
                         end

    [].tap do |ary|
      number_of_children.times do |n|
        ary << if children && children[n.to_s] && valid_date_params?(children[n.to_s][:start])
                 StartingChild.new(children[n.to_s])
               else
                 StartingChild.new
               end
      end
    end
  end

  def first_child_rate_total(no_of_weeks)
    @child_benefit_rates.first_child_rate * no_of_weeks
  end

  def additional_child_rate_total(no_of_weeks, no_of_children)
    @child_benefit_rates.additional_child_rate * no_of_children * no_of_weeks
  end

  def calculate_adjusted_net_income(adjusted_net_income)
    if @adjusted_net_income_calculator.can_calculate?
      @adjusted_net_income_calculator.calculate_adjusted_net_income
    elsif adjusted_net_income.present?
      adjusted_net_income.gsub(/[£, -]/, "").to_i
    end
  end

  def valid_child_dates
    is_part_year_claim == "yes" && @starting_children.each(&:valid?)
  end

  def valid_number_of_children
    if @is_part_year_claim == "yes" && (@children_count < @part_year_children_count)
      errors.add(:part_year_children_count, "the number of children you're claiming a part year for can't be more than the total number of children you're claiming for")
    end
  end

  def tax_year_contains_at_least_one_child
    return unless selected_tax_year.present? && @starting_children.select(&:valid?).any?

    in_tax_year = @starting_children.reject { |c| c.start_date.nil? || c.start_date > selected_tax_year.last || (c.end_date.present? && c.end_date < selected_tax_year.first) }
    if in_tax_year.empty?
      @starting_children.first.errors.add(:end_date, "You haven't received any Child Benefit for the tax year selected. Check your Child Benefit dates or choose a different tax year.")
    end
  end
end
