class StartingChild
  include ActiveModel::Validations

  validates_presence_of :start_date, :message => "Enter the date Child Benefit started"
  validate :valid_dates

  attr_reader :start_date, :end_date

  def initialize(params = {})
    if ChildBenefitTaxCalculator.valid_date_params?(params[:start])
      @start_date = Date.new(params[:start][:year].to_i,
                             params[:start][:month].to_i,
                             params[:start][:day].to_i)
    end

    if ChildBenefitTaxCalculator.valid_date_params?(params[:stop])
      @end_date = Date.new(params[:stop][:year].to_i,
                           params[:stop][:month].to_i,
                           params[:stop][:day].to_i)
    end
  end

  def benefits_end
    tax_years = ChildBenefitTaxCalculator::TAX_YEARS
    @end_date ? @end_date : tax_years[tax_years.keys.sort.last].last
  end

  def adjusted_start_date
    return @start_date if @start_date === Date.parse("7 January 2013")
    next_monday_for_date(@start_date)
  end

  private

  def next_monday_for_date(date)
    date.advance(:days => 8 - date.wday)
  end

  def valid_dates
    if @start_date and @end_date and @start_date >= @end_date
      errors.add(:end_date, "Child Benefit start date must be before stop date")
    end
  end
end
