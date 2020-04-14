# encoding: utf-8

class ChildBenefitRates
  attr_reader :year

  RATES = {
    2016 => [20.7, 13.7],
    2017 => [20.7, 13.7],
    2018 => [20.7, 13.7],
    2019 => [20.7, 13.7],
    2020 => [21.05, 13.95],
  }.freeze

  def initialize(year)
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
