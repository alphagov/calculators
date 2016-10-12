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
      schema_name: 'placeholder_calculator',
      document_type: 'calculator',
      details: {},
      publishing_app: 'calculators',
      rendering_app: 'calculators',
      locale: 'en',
      public_updated_at: Time.now.iso8601,
      routes: [
        { type: 'exact', path: base_path }
      ]
    }
  end
end
