require 'spec_helper'

describe CalculatorPublisher do
  describe '#publish' do
    it 'publishes the content item' do
      expect(Services.publishing_api).to receive(:put_content).with('0e1de8f1-9909-4e45-a6a3-bffe95470275', be_valid_against_schema('generic'))
      expect(Services.publishing_api).to receive(:publish).with('0e1de8f1-9909-4e45-a6a3-bffe95470275', 'minor')
      expect(Services.publishing_api).to receive(:patch_links).with(
        '0e1de8f1-9909-4e45-a6a3-bffe95470275',
        links:
          {
            meets_user_needs: ["ccb9f417-ac8d-4ff5-80ea-695c86dac9fb"]
          }
      )

      calendar = Calculator.all.first

      CalculatorPublisher.new(calendar).publish
    end
  end
end
