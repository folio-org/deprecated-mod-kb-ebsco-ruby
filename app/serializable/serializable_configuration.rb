class SerializableConfiguration < SerializableResource
  type 'configurations'

  attributes :api_key, :customer_id
end
