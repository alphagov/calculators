require_relative "../../test_helper"

class ChildBenefitRatesTest < ActiveSupport::TestCase
  context ChildBenefitRates do
    setup do
      @year = 2014
      @first_child_rate = 42.42
      @additional_child_rate = 13.17
      @calculator = ChildBenefitRates.new(@year)
      @rates = { @year => [@first_child_rate, @additional_child_rate] }
      @calculator.stubs(:rates_for_year).returns(@rates[@year])
    end

    context "#year" do
      should "return the year passed during initialization" do
        assert_equal @year, @calculator.year
      end
    end

    context "#first_child_rate" do
      should "return correct rates" do
        assert_equal @first_child_rate, @calculator.first_child_rate
      end
    end

    context "#additional_child_rate" do
      should "return correct rates" do
        assert_equal @additional_child_rate, @calculator.additional_child_rate
      end
    end
  end
end
