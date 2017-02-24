require "spec_helper"

RSpec.describe SearchIndexer do
  describe ".call" do
    it "sends a document to Rummager" do
      calculator = Calculator.all.first
      expect(Services.rummager).to receive(:add_document).with(
        "edition",
        "/child-benefit-tax-calculator",
        content_id: "0e1de8f1-9909-4e45-a6a3-bffe95470275",
        rendering_app: "calculators",
        publishing_app: "calculators",
        format: "custom-application",
        title: "Child Benefit tax calculator",
        description: "Work out the Child Benefit you've received and your High Income Child Benefit tax charge.",
        indexable_content: [
          "Work out the Child Benefit you've received and your High Income Child Benefit tax charge",
          "Use this tool to work out",
          "how much Child Benefit you receive in a tax year",
          "the High Income Child Benefit tax charge you or your partner may have to pay",
          "You're affected by the tax charge if your income is over £50,000.",
          "Your partner is responsible for paying the tax charge if their income is more than £50,000 and higher than yours.",
          "You'll need the dates Child Benefit started and, if applicable, stopped.",
        ].join(" "),
        link: "/child-benefit-tax-calculator",
        content_store_document_type: "calculator",
      )
      SearchIndexer.call(calculator)
    end
  end
end
