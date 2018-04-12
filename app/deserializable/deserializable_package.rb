# frozen_string_literal: true

class DeserializablePackage < JSONAPI::Deserializable::Resource
  attributes :isSelected,
             :customCoverage,
             :visibilityData,
             :contentType

  attribute :allowKbToAddTitles do |value|
    { allowEbscoToAddTitles: value }
  end

  attribute :name do |value|
    { packageName: value }
  end

  attribute :contentType do |value|
    content_types = {
      'All': 'all',
      'Aggregated Full Text': 'aggregatedfulltext',
      'Abstract and Index': 'abstractandindex',
      'E-Book': 'ebook',
      'E-Journal': 'ejournal',
      'Print': 'print',
      'Unknown': 'unknown',
      'Online Reference': 'onlinereference'
    }

    { contentType: content_types[value.to_sym] || 'unknown' }
  end
end
