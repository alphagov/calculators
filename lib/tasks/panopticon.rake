# encoding: utf-8

namespace :panopticon do
  desc "Register application metadata with panopticon"
  task register: :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."

    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "calculators")

    Calculator.all.each do |calculator|
      registerer.register(calculator)
    end
  end
end
