# frozen_string_literal: true

class SerializableProxyType < SerializableJSONAPIResource
  type 'proxyType'

  # Custom Label attributes
  attributes :id,
             :name,
             :url_mask
end
