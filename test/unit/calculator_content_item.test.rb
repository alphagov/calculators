require_relative "../test_helper"

class CalculatorContentItemTest < ActiveSupport::
  TestCase
  include GovukContentSchemaTestHelpers::TestUnit
  context CalculatorContentItem do
    context "#payload" do
      should "be valid against the schema" do
        calculator = Calculator.all.first
        payload = CalculatorContentItem.new(calculator).payload
        assert_valid_against_schema payload, "generic"
      end

      should "have the correct data" do
        calculator = Calculator.all.first
        payload = CalculatorContentItem.new(calculator).payload
        assert_equal payload[:title], "Child Benefit tax calculator"
      end

      should "use a prefix route" do
        calculator = Calculator.all.first
        payload = CalculatorContentItem.new(calculator).payload
        assert_equal payload[:routes].first[:type], "prefix"
      end
    end
    
    context "#content_id" do
      should "have the correct content_id" do
        calculator = Calculator.all.first
        content_id = CalculatorContentItem.new(calculator).content_id
        assert_equal content_id, "882aecb2-90c9-49b1-908d-c800bf22da5a"
      end
    end

    context "#base_path" do
      should "have the correct base path" do
        calculator = Calculator.all.first
        base_path = CalculatorContentItem.new(calculator).base_path
        assert_equal base_path, "/child-benefit-tax-calculator/main"
      end
    end    
  end
end