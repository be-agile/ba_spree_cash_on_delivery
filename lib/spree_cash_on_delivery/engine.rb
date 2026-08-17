module SpreeCashOnDelivery
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_cash_on_delivery'

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.after_initialize do |app|
      # Add the payment method to the list of available payment methods
      app.config.spree.payment_methods << Spree::PaymentMethod::CashOnDelivery
    end

    initializer 'spree_cash_on_delivery.autoloader' do |app|
      if Rails.autoloaders.zeitwerk_enabled?
        Rails.autoloaders.main.ignore("#{root}/app/overrides")
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
