class DeserializablePackage < JSONAPI::Deserializable::Resource
  attributes :isSelected,
             :customCoverage

  attribute :isHidden do |value|
    { visibilityData: { isHidden: value } }
  end
end
