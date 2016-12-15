class CalculatorPublisher
  def initialize(calculator)
    @calculator = calculator
  end

  def publish
    Services.publishing_api.put_content(rendered.content_id, rendered.payload)
    Services.publishing_api.publish(rendered.content_id, rendered.update_type)
    Services.publishing_api.patch_links(rendered.content_id, links: rendered.links)
  end

private

  def rendered
    @rendered ||= CalculatorContentItem.new(@calculator)
  end
end
