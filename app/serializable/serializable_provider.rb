# frozen_string_literal: true

class SerializableProvider < SerializableResource
  type 'providers'

  attribute :name do
    @object.vendorName
  end

  attributes :packagesTotal,
             :packagesSelected

  attribute :providerToken do
    @object.vendorToken
  end

  has_many :packages
end
