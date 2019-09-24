require "spec_helper"

describe CalculatorContentItem do
  describe "#payload" do
    it "is valid against the schema" do
      calculator = Calculator.all.first

      payload = CalculatorContentItem.new(calculator).payload

      expect(payload).to be_valid_against_schema("generic")
    end

    it "has the correct data" do
      calculator = Calculator.all.first

      payload = CalculatorContentItem.new(calculator).payload

      expect(payload[:title]).to eql("Child Benefit tax calculator")
    end

    it "uses a prefix route" do
      calculator = Calculator.all.first

      payload = CalculatorContentItem.new(calculator).payload

      expect(payload[:routes].first[:type]).to eql("prefix")
    end
  end

  describe "#content_id" do
    it "has the correct content_id" do
      calculator = Calculator.all.first

      content_id = CalculatorContentItem.new(calculator).content_id

      expect(content_id).to eql("882aecb2-90c9-49b1-908d-c800bf22da5a")
    end
  end

  describe "#base_path" do
    it "has the correct base path" do
      calculator = Calculator.all.first

      base_path = CalculatorContentItem.new(calculator).base_path

      expect(base_path).to eql("/child-benefit-tax-calculator/main")
    end
  end
end
