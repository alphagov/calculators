Calculators::Application.routes.draw do
  get "/child-benefit-tax-calculator" => "child_benefit_tax#landing"
  post "/child-benefit-tax-calculator" => "child_benefit_tax#landing"
end
