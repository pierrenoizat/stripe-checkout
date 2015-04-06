require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsStripeCheckout
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    
    config.i18n.enforce_available_locales = false
    
    config.i18n.available_locales = [:en, :fr]
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales','**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :fr

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    
    $MPK = 'c56b2f46fe68c07d616ab218019fb9065493590a4bb1fb030c51d532c5598b6a834e4595e4cb7f89f07d409659078b7aa5d47026cf887ee6658910eb1d38629a'
    # $PRODUCT_PRICE = 50
    $MIN_STRIPE_AMOUNT = 50
    
    AWS.config(access_key_id: 'AKIAISHH6QIJ3R7Q2HXQ', secret_access_key: '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', region: 'eu-west-1')
    
    config.paperclip_defaults = {
      :storage => :s3,
      :s3_protocol => 'http',
      :s3_credentials => {
        :bucket => 'hashtree-assets'
      }
    }
    
  end
end
