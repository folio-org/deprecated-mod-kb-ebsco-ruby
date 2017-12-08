class DeserializableCustomerResource < JSONAPI::Deserializable::Resource
  attributes :isSelected,
             :customEmbargoPeriod,
             :visibilityData

  attribute :customCoverages do |value|
    { customCoverageList: value }
  end
end
