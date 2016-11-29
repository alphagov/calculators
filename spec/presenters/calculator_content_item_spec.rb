require 'spec_helper'

describe CalculatorContentItem do
  describe '#payload' do
    it 'is valid against the schema' do
      calculator = Calculator.all.first

      payload = CalculatorContentItem.new(calculator).payload

      expect(payload).to be_valid_against_schema('generic')
    end

    it 'has the correct data' do
      calculator = Calculator.all.first

      payload = CalculatorContentItem.new(calculator).payload

      expect(payload[:title]).to eql('Child Benefit tax calculator')
    end
  end

  describe '#base_path' do
    it 'has the correct base path' do
      calculator = Calculator.all.first

      base_path = CalculatorContentItem.new(calculator).base_path

      expect(base_path).to eql("/child-benefit-tax-calculator")
    end
  end
end
