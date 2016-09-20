class SearchPayload
  attr_reader :calculator
  delegate :slug,
           :title,
           :description,
           :indexable_content,
           :content_id,
           to: :calculator

  def initialize(calculator)
    @calculator = calculator
  end

  def self.present(calculator)
    new(calculator).present
  end

  def present
    {
      content_id: content_id,
      rendering_app: "calculators",
      publishing_app: "calculators",
      format: "custom-application",
      title: title,
      description: description,
      indexable_content: indexable_content,
      link: "/#{slug}",
    }
  end
end
