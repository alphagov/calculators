class CalculatorPublisher
  def initialize(calculator)
    @calculator = calculator
  end

  def publish
    GdsApi.publishing_api.put_content(rendered.content_id, rendered.payload)
    GdsApi.publishing_api.publish(rendered.content_id)
  end

private

  def rendered
    @rendered ||= CalculatorContentItem.new(@calculator)
  end
end
