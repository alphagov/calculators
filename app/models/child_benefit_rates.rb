# encoding: UTF-8
class ChildBenefitRates

  attr_reader :year

  RATES = {
    2012 => [20.3, 13.4],
    2013 => [20.3, 13.4],
    2014 => [20.5, 13.55],
    2015 => [20.7, 13.7],
  }

  def initialize(year)
    raise "Invalid tax year" unless RATES.keys.include?(year)
    @year = year
  end

  def first_child_rate
    rates_for_year.first
  end

  def additional_child_rate
    rates_for_year.second
  end

private
  def rates_for_year
    RATES[year]
  end

end
