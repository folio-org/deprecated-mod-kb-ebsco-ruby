class StatusResource < JSONAPI::Resource
  attributes :is_configuration_valid

  def id
    "status"
  end

  def self.find_by_key(key, options = {})
    context = options[:context]
    okapi = context[:okapi]
    config = Configuration.new(okapi)
    config.load!
    model = Status.new(config)

    resource_for_model(model).new(model, context)
  end

  def is_configuration_valid
    @model.configuration_valid?
  end
end
