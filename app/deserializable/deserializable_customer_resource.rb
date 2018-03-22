# frozen_string_literal: true

class DeserializableCustomerResource < JSONAPI::Deserializable::Resource
  attributes :isSelected,
             :customEmbargoPeriod,
             :visibilityData,
             :coverageStatement

  attribute :customCoverages do |value|
    { customCoverageList: value }
  end
end
