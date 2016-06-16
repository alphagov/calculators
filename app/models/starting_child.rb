class StartingChild
  include ActiveModel::Validations

  validates_presence_of :start_date,
                        message: "enter the date Child Benefit started",
                        unless: :start_date_with_too_many_days?

  validate :valid_dates

  attr_accessor :start_date, :end_date

  def initialize(params = {})
    @dates_with_too_many_days = []
    set_date(:start_date, params[:start])
    set_date(:end_date, params[:stop])
  end

  def benefits_end
    tax_years = ChildBenefitTaxCalculator::TAX_YEARS
    @end_date ? @end_date : tax_years[tax_years.keys.sort.last].last
  end

  # Return the date of the Monday in the future that is closest to the start_date.
  # If the start_date is a Monday, use the start_date.
  def adjusted_start_date
    return nil if start_date.nil?

    if start_date.wday < 1
      start_date + 1.day
    elsif start_date.wday > 1
      number_of_days_til_next_monday = ((1 - start_date.wday) + 7)
      start_date + number_of_days_til_next_monday
    else
      start_date
    end
  end

private

  def valid_dates
    @dates_with_too_many_days.each do |error|
      msg = "enter a valid date - there are only #{error[:max_days]} days in #{error[:month]}"
      errors.add(error[:date_attr], msg)
    end
    if @start_date && @end_date && @start_date >= @end_date
      errors.add(:end_date, "child Benefit start date must be before stop date")
    end
  end

  def set_date(date_attr, date_params)
    if date_params && buildable_date?(date_attr, date_params)
      self.send(
        "#{date_attr}=",
        Date.new(
          date_params[:year].to_i,
          date_params[:month].to_i,
          date_params[:day].to_i,
        ),
      )
    end
  end

  def buildable_date?(date_attr, date_params)
    date_values_present?(date_params) &&
      valid_day_for_month_in_year?(
        date_attr, date_params)
  end

  def date_values_present?(date_params)
    date_params[:year].present? &&
      date_params[:month].present? &&
      date_params[:day].present?
  end

  def valid_day_for_month_in_year?(date_attr, date_params)
    month_in_year = Date.new(
      date_params[:year].to_i, date_params[:month].to_i, 1)
    day = date_params[:day].to_i
    max_days = month_in_year.end_of_month.day
    if day > max_days
      @dates_with_too_many_days << {
        date_attr: date_attr, month: month_in_year.strftime("%B"), max_days: max_days }
      return false
    end
    true
  end

  def start_date_with_too_many_days?
    @dates_with_too_many_days.select { |e| e.has_value?(:start_date) }.any?
  end
end
