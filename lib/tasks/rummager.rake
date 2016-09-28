namespace :rummager do
  desc "Indexes all calculators in Rummager"
  task index: :environment do
    require 'gds_api/rummager'

    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Sending application data to rummager..."

    Calculator.all.each do |calculator|
      SearchIndexer.call(calculator)
    end
  end
end
