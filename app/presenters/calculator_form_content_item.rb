# Renders a content-item for the calculator form for the publishing-api.
class CalculatorFormContentItem < CalculatorContentItem
  attr_reader :calculator

  def base_path
    "/#{calculator.slug}/main"
  end

  def content_id
    "882aecb2-90c9-49b1-908d-c800bf22da5a"
  end
end
