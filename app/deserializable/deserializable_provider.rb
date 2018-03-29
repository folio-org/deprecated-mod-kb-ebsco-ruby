# frozen_string_literal: true

class DeserializableProvider < JSONAPI::Deserializable::Resource
  attribute :providerToken do |value|
    { vendorToken: value }
  end
end
