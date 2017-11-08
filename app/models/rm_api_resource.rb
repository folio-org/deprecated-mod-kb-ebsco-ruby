class RmApiResource < Flexirest::Base
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  before_request :add_headers
  before_request :add_customer_id

  base_url "#{ENV.fetch('EBSCO_RESOURCE_MANAGEMENT_API_BASE_URL', 'https://sandbox.ebsco.io')}/rm/rmaccounts"

  def persisted?
    id.present?
  end

  private

  def self.configure(config)
    # TODO: is a class variable the right thing to do here?
    # also maybe we should take rmapi_base_url in here instead
    @@config ||= config
  end

  def add_headers(name, request)
    request.headers['X-Api-Key'] = @@config.api_key
    request.headers['Content-Type'] = 'application/json'
    request.headers['Accept'] = 'application/json'
  end

  def add_customer_id(name, request)
    request.url.gsub!("#customer_id", @@config.customer_id)
  end
end
