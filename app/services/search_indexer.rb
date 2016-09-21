class SearchIndexer
  attr_reader :calculator
  delegate :slug, to: :calculator

  def initialize(calculator)
    @calculator = calculator
  end

  def self.call(calculator)
    new(calculator).call
  end

  def call
    Services.rummager.add_document(type, document_id, payload)
  end

private

  def type
    'edition'
  end

  def document_id
    "/#{slug}"
  end

  def payload
    SearchPayload.present(calculator)
  end
end
