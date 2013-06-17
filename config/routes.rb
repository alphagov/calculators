Calculators::Application.routes.draw do
  get "/child-benefit-tax-calculator" => "child_benefit_tax#landing", :format => false
  get "/child-benefit-tax-calculator/main" => "child_benefit_tax#main", :format => false
  get "/child-benefit-tax-calculator/process_form" => "child_benefit_tax#process_form", :format => false
end
