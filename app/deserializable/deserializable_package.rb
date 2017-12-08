class DeserializablePackage < JSONAPI::Deserializable::Resource
  attributes :isSelected,
             :customCoverage,
             :visibilityData
end
