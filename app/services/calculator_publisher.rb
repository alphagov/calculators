class CalculatorPublisher
  def initialize(calculator)
    @calculator = calculator
  end

  def publish
    rendered.each do |content_item|
      Services.publishing_api.put_content(content_item.content_id, content_item.payload)
      Services.publishing_api.publish(content_item.content_id, content_item.update_type)
    end
  end

private

  def rendered
    @rendered ||= [start_page_content_item, form_content_item]
  end

  def start_page_content_item
    CalculatorContentItem.new(@calculator)
  end

  def form_content_item
    CalculatorFormContentItem.new(@calculator)
  end
end
