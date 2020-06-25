require_relative "../../test_helper"

class CalculatorPublisherTest < ActiveSupport::TestCase
  include GovukContentSchemaTestHelpers::TestUnit
  context CalculatorPublisher do
    context "#publish" do
      should "publish content items for form" do
        payload = Services.publishing_api.stubs(:put_content).with("882aecb2-90c9-49b1-908d-c800bf22da5a")
        assert_valid_against_schema payload, "generic"

        assert Services.publishing_api.stubs(:publish).with("882aecb2-90c9-49b1-908d-c800bf22da5a")

        calendar = Calculator.all.first
        CalculatorPublisher.new(calendar).publish

      end
    end
  end
end
