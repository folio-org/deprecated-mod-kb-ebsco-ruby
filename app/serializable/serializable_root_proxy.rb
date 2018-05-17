# frozen_string_literal: true

class SerializableRootProxy < SerializableJSONAPIResource
  type 'rootProxies'

  # Custom Label attributes
  attributes :id
  attributes :proxy_type_id
end
