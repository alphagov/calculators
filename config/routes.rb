Calculators::Application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide"

  root to: redirect("/child-benefit-tax-calculator/main")

  with_options format: false do
    get "/child-benefit-tax-calculator/main" => "child_benefit_tax#main"
    get "/child-benefit-tax-calculator/main/process_form" => "child_benefit_tax#process_form"
  end
end
