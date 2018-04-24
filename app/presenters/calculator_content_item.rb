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

  def route_type
    'prefix'
  end

  def payload
    {
      title: calculator.title,
      description: calculator.description,
      base_path: base_path,
      schema_name: 'generic',
      document_type: 'calculator',
      details: {},
      publishing_app: 'calculators',
      rendering_app: 'calculators',
      locale: 'en',
      routes: [
        { type: route_type, path: base_path }
      ],
      update_type: update_type,
    }
  end
end
