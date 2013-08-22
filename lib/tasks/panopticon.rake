# encoding: utf-8

namespace :panopticon do

  desc "Register application metadata with panopticon"
  task :register => :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."

    registerer = GdsApi::Panopticon::Registerer.new(owning_app: "calculators")

    calculators = [
      OpenStruct.new({
        :title => "Child Benefit tax calculator",
        :slug => "child-benefit-tax-calculator",
        :need_id => "2482",
        :state => "live",
        :description => "Work out the Child Benefit you've received and your High Income Child Benefit tax charge",
        :indexable_content => [
          "Work out the Child Benefit you've received and your High Income Child Benefit tax charge",
          "Use this tool to work out",
          "how much Child Benefit you receive in a tax year",
          "the High Income Child Benefit tax charge you or your partner may have to pay",
          "You're affected by the tax charge if your income is over £50,000.",
          "Your partner is responsible for paying the tax charge if their income is more than £50,000 and higher than yours.",
          "You'll need the dates Child Benefit started and, if applicable, stopped.",
        ].join(" "),
      }),
    ]
    calculators.each do |calculator|
      registerer.register(calculator)
    end
  end
end

