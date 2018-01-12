# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module ModKbEbsco
  class Application < Rails::Application
    config.load_defaults 5.1
    config.api_only = true

    def config.rmapi_base_url
      ENV.fetch('EBSCO_RMAPI_BASE_URL', 'https://api.ebsco.io')
    end
  end
end
