require 'spec_helper'

describe CalculatorPublisher do
  describe '#publish' do
    it 'publishes the content item' do
      allow(Services.publishing_api).to receive(:put_content_item)
      calendar = Calculator.all.first

      CalculatorPublisher.new(calendar).publish

      expect(Services.publishing_api).to have_received(:put_content_item).with(
        "/child-benefit-tax-calculator",
        be_valid_against_schema('placeholder')
      )
    end
  end
end
