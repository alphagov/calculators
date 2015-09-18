# Renders a calculator for the publishing-api.
class CalculatorContentItem
  attr_reader :calculator

  def initialize(calculator)
    @calculator = calculator
  end

  def base_path
    '/' + calculator.slug
  end

  def payload
    {
      title: calculator.title,
      content_id: calculator.content_id,
      format: 'placeholder_calculator',
      publishing_app: 'calculators',
      rendering_app: 'calculators',
      update_type: 'minor',
      locale: 'en',
      public_updated_at: Time.now.iso8601,
      routes: [
        { type: 'exact', path: base_path }
      ]
    }
  end
end
