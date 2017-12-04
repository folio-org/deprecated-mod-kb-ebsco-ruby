class DeserializableCustomerResource < JSONAPI::Deserializable::Resource
  attributes :isSelected,
             :customEmbargoPeriod

  attribute :customCoverages do |value|
    { customCoverageList: value }
  end

  attribute :isHidden do |value|
    { visibilityData: { isHidden: value } }
  end
end
