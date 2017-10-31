class SerializableVendor < SerializableResource
  type 'vendors'

  attributes :name, :packages_total, :packages_selected
end
