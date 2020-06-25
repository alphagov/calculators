require_relative "../test_helper"

class ChildBenefitTaxHelperTest < ActiveSupport::TestCase
  include ChildBenefitTaxHelper
  
  context "money_input_value" do
    should "convert a number into a monetary value" do
      assert_equal ApplicationController.helpers.money_input_value(1001), "£1,001.00"
    end

    should "return nothing if the number is zero" do
      assert_nil ApplicationController.helpers.money_input_value(0)
    end
  end

  context "tax_year_label" do
    should "format the years range" do
      Timecop.travel("2020-04-02") do
        assert_equal ApplicationController.helpers.tax_year_label(2016), "2016 to 2017"
      end
    end
  end

  context "tax_year_incomplete?" do
    setup do
      # not sure how to do this in minitest, I think it might need to be a mock but I can't work it out
      @calculator = double(tax_year: 2019)
    end

    should "be true before the end of the tax year" do
      Timecop.freeze("2020-04-04") do
        require 'pry'; binding.pry;
        tax_year_incomplete?
        assert ApplicationController.helpers.tax_year_incomplete?
      end
    end

    should "be false after the end of the tax year" do
      Timecop.freeze("2020-04-06") do
        assert_not ApplicationController.helpers.tax_year_incomplete?
      end
    end
  end
end

