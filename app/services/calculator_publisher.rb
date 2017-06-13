class CalculatorPublisher
  def initialize(calculator)
    @calculator = calculator
  end

  def publish
    Services.publishing_api.put_content(rendered.content_id, rendered.payload)
    Services.publishing_api.publish(rendered.content_id, rendered.update_type)
  end

private

  def rendered
    @rendered ||= CalculatorFormContentItem.new(@calculator)
  end
end
