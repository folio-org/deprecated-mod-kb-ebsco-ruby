require 'okapi'

class ConfigurationResource < JSONAPI::Resource
  attributes :customer_id, :api_key

  def self.find_by_key(key, options = {})
    context = options[:context]
    okapi = context[:okapi]
    model = Configuration.new(okapi)
    model.load!

    resource_for_model(model).new(model, context)
  end

  def model_error_messages
     {default: @model.errors}
  end
end
