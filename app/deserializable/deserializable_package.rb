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
      'All': 'All',
      'Aggregated Full Text': 'AggregatedFullText',
      'Abstract and Index': 'AbstractAndIndex',
      'E-Book': 'EBook',
      'E-Journal': 'EJournal',
      'Print': 'Print',
      'Unknown': 'Unknown',
      'Online Reference': 'OnlineReference'
    }

    { contentType: content_types[value.to_sym] || 'Unknown' }
  end
end
