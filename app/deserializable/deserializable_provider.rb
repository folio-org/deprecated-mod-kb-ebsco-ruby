# frozen_string_literal: true

class DeserializableProvider < JSONAPI::Deserializable::Resource
  attributes :proxy

  attribute  :providerToken do |value|
    { vendorToken: value }
  end
end
