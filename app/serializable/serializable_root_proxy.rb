# frozen_string_literal: true

class SerializableRootProxy < SerializableJSONAPIResource
  type 'rootProxy'

  # Custom Label attributes
  attributes :id,
             :name,
             :url_mask,
             :selected
end
