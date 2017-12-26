# frozen_string_literal: true

class DeserializablePackage < JSONAPI::Deserializable::Resource
  attributes :isSelected,
             :customCoverage,
             :visibilityData
end
