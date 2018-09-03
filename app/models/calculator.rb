class Calculator
  ALL = [{
    title: "Child Benefit tax calculator",
    slug: "child-benefit-tax-calculator/main",
    content_id: "882aecb2-90c9-49b1-908d-c800bf22da5a",
    description: "Work out the Child Benefit you've received and your High Income Child Benefit tax charge.",
  }].freeze

  def self.all
    ALL.map { |hash| OpenStruct.new(hash) }
  end
end
