module DateHelper
  def self.day(date = nil)
    if date.present?
      Date.parse(date)
    else
      Date.today
    end
  end

  def self.years_ago(period = 10, date = nil)
    period.years.ago(day(date))
  end

  def self.years_since(period = 10, date = nil)
    period.years.since(day(date))
  end
end
