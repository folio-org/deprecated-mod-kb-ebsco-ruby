require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module ModKbEbsco
  class Application < Rails::Application
    config.load_defaults 5.1
    config.api_only = true

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'folio.frontside.io'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end
  end
end
