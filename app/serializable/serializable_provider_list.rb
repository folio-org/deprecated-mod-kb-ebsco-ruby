# frozen_string_literal: true

class SerializableProviderList < SerializableJSONAPIResource
  type 'providers'

  attribute :name do
    @object.vendorName
  end

  attributes :packagesTotal,
             :packagesSelected

  attribute :providerToken do
    @object.vendorToken
  end

  attribute :supportsCustomPackages do
    @object.isCustomer
  end

  has_many :packages
end
