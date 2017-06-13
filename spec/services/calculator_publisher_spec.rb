require 'spec_helper'

describe CalculatorPublisher do
  describe '#publish' do
    it 'publishes content items for form' do
      # Start page
      expect(Services.publishing_api).not_to receive(:put_content).with('0e1de8f1-9909-4e45-a6a3-bffe95470275', be_valid_against_schema('generic'))
      expect(Services.publishing_api).not_to receive(:publish).with('0e1de8f1-9909-4e45-a6a3-bffe95470275', 'minor')

      # Form
      expect(Services.publishing_api).to receive(:put_content).with('882aecb2-90c9-49b1-908d-c800bf22da5a', be_valid_against_schema('generic'))
      expect(Services.publishing_api).to receive(:publish).with('882aecb2-90c9-49b1-908d-c800bf22da5a', 'minor')

      calendar = Calculator.all.first
      CalculatorPublisher.new(calendar).publish
    end
  end
end
