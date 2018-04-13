# frozen_string_literal: true

class SerializableStatus < SerializableJSONAPIResource
  type 'statuses'

  attribute :is_configuration_valid do
    @object.configuration_valid?
  end
end
