# Renders a calculator for the publishing-api.
class CalculatorContentItem
  attr_reader :calculator

  def initialize(calculator)
    @calculator = calculator
  end

  def base_path
    '/' + calculator.slug
  end

  def content_id
    calculator.content_id
  end

  def update_type
    'minor'
  end

  def payload
    {
      title: calculator.title,
      base_path: base_path,
      schema_name: 'generic',
      document_type: 'calculator',
      details: {},
      publishing_app: 'calculators',
      rendering_app: 'calculators',
      locale: 'en',
      public_updated_at: Time.now.iso8601,
      routes: [
        { type: 'prefix', path: base_path }
      ]
    }
  end

  def links
    {
      meets_user_needs: ["ccb9f417-ac8d-4ff5-80ea-695c86dac9fb"]
    }
  end
end
