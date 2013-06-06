Calculators::Application.routes.draw do
  get "/child-benefit-tax-calculator" => "child_benefit_tax#landing", :format => false
  get "/child-benefit-tax-calculator/main" => "child_benefit_tax#main", :format => false
  post "/child-benefit-tax-calculator/main" => "child_benefit_tax#main"
end
