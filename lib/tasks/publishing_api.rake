namespace :publishing_api do
  desc "Send pages to the Publishing API"
  task publish: [:environment] do
    Calculator.all.each do |calculator|
      CalculatorPublisher.new(calculator).publish
    end
  end
end
