Calculators::Application.routes.draw do
  with_options format: false do |routes|
    routes.get "/child-benefit-tax-calculator/main" => "child_benefit_tax#main"
    routes.get "/child-benefit-tax-calculator/main/process_form" => "child_benefit_tax#process_form"
  end
end
