# frozen_string_literal: true

class SerializableVendor < SerializableJSONAPIResource
  type 'vendors'

  attribute :name do
    @object.vendorName
  end

  attributes :packagesTotal,
             :packagesSelected

  has_many :packages
end
