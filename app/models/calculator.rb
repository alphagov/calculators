class Calculator
  ALL = [{
    title: "Child Benefit tax calculator",
    slug: "child-benefit-tax-calculator",
    content_id: "0e1de8f1-9909-4e45-a6a3-bffe95470275",
    need_id: "100266",
    state: "live",
    description: "Work out the Child Benefit you've received and your High Income Child Benefit tax charge.",
  }]

  def self.all
    ALL.map { |hash| OpenStruct.new(hash) }
  end
end
