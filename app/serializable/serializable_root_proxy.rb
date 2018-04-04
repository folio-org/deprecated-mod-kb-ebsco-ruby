# frozen_string_literal: true

class SerializableRootProxy < SerializableResource
  type 'rootProxy'

  # Custom Label attributes
  attributes :id,
             :name,
             :url_mask,
             :selected
end
