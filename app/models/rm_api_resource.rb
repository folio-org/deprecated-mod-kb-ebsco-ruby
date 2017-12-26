# frozen_string_literal: true

class RmApiResource < Flexirest::Base
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  before_request :set_base_url
  before_request :add_headers

  def persisted?
    id.present?
  end

  ##
  # Get a subclass of this resource configured to
  # talk with the RMAPI using the configured tenants
  # Credentials.
  #
  # Having our Flexirest resources configured is great, but each one
  # needs use the correct credentials in order to make its
  # requests. However, all of the finders exist on the Class
  # level. E.g. `Title.find(title_id)` and `Title.all(q:
  # params[:q])`. In order to preserve the finders, we return a new,
  # anonymous class that contains the per-request configuration so
  # they work the same, just scoped to this particular request:
  #
  #   Title.configure(config).find(title_id)
  #   Title.configure(config).all(q: params[:q])
  def self.configure(config)
    Class.new(self).tap do |subclass|
      subclass.verbose!

      # In order for JSONAPI to render, it needs the class to have a
      # name like "Title" so that it can look up the
      # `SerializableTitle` class. Anonymous classes have no name, so
      # we just name it after the superclass
      name = self.name
      subclass.send(:define_singleton_method, :name) { name }

      # store the configuration on the anonymous subclass
      subclass.send(:define_singleton_method, :config) { config }
      subclass.send(:define_method, :config) { config }

      # Flexirest erases all of the mapped API calls whenever you
      # create a subclass. This copies over those calls into the new
      # subclass so that all of the finders continue to work.
      subclass.instance_variable_set(:@_calls, _calls)
    end
  end

  private

  def set_base_url(_name, request)
    rmapi_url = ENV.fetch(
      'EBSCO_RESOURCE_MANAGEMENT_API_BASE_URL',
      'https://sandbox.ebsco.io'
    )
    customer_id = request.object.config.customer_id
    self.class.base_url "#{rmapi_url}/rm/rmaccounts/#{customer_id}"
  end

  def add_headers(_name, request)
    request.headers['X-Api-Key'] = request.object.config.api_key
    request.headers['Content-Type'] = 'application/json'
    request.headers['Accept'] = 'application/json'
  end
end
