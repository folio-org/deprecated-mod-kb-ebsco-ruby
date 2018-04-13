# frozen_string_literal: true

class SerializableConfiguration < SerializableJSONAPIResource
  type 'configurations'

  attributes :api_key, :customer_id
end
