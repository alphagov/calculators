Calculators::Application.routes.draw do

  get "/child-benefit-tax-calculator" => Proc.new {[200, {}, ["Placeholder landing page"]]}
end
