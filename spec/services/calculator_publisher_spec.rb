require "spec_helper"

describe CalculatorPublisher do
  describe "#publish" do
    it "publishes content items for form" do
      expect(Services.publishing_api).to receive(:put_content).with("882aecb2-90c9-49b1-908d-c800bf22da5a", be_valid_against_schema("generic"))
      expect(Services.publishing_api).to receive(:publish).with("882aecb2-90c9-49b1-908d-c800bf22da5a")

      calendar = Calculator.all.first
      CalculatorPublisher.new(calendar).publish
    end
  end
end
