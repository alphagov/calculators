Calculators::Application.routes.draw do
  get "/child-benefit-tax-calculator" => "child_benefit_tax#landing"
  get "/child-benefit-tax-calculator/main" => "child_benefit_tax#main"
  post "/child-benefit-tax-calculator/main" => "child_benefit_tax#main"
end
