# frozen_string_literal: true

class SerializableProvider < SerializableJSONAPIResource
  type 'providers'

  attribute :name do
    @object.vendorName
  end

  attributes :packagesTotal,
             :packagesSelected,
             :proxy

  attribute :providerToken do
    @object.vendorToken
  end

  attribute :supportsCustomPackages do
    @object.isCustomer
  end

  has_many :packages
end
