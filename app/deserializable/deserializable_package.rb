# frozen_string_literal: true

class DeserializablePackage < JSONAPI::Deserializable::Resource
  attributes :isSelected,
             :customCoverage,
             :visibilityData

  attribute :allowKbToAddTitles do |value|
    { allowEbscoToAddTitles: value }
  end
end
