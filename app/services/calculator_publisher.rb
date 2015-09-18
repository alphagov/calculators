class CalculatorPublisher
  def initialize(calculator)
    @calculator = calculator
  end

  def publish
    Services.publishing_api.put_content_item(rendered.base_path, rendered.payload)
  end

private

  def rendered
    @rendered ||= CalculatorContentItem.new(@calculator)
  end
end
