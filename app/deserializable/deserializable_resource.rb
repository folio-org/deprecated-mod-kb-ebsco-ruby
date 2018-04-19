# frozen_string_literal: true

class DeserializableResource < JSONAPI::Deserializable::Resource
  attributes :isSelected,
             :customEmbargoPeriod,
             :visibilityData,
             :coverageStatement,
             :isPeerReviewed,
             :publisherName,
             :edition,
             :description,
             :url,
             :packageId

  attribute :name do |value|
    { titleName: value }
  end

  attribute :publicationType do |value|
    publication_types = {
      'All': 'all',
      'Audiobook': 'audiobook',
      'Book': 'book',
      'Book Series': 'bookseries',
      'Database': 'database',
      'Journal': 'journal',
      'Newsletter': 'newsletter',
      'Newspaper': 'newspaper',
      'Proceedings': 'proceedings',
      'Report': 'report',
      'Streaming Audio': 'streamingaudio',
      'Streaming Video': 'streamingvideo',
      'Thesis & Dissertation': 'thesisdissertation',
      'Website': 'website',
      'Unspecified': 'unspecified'
    }

    { pubType: publication_types[value.to_sym] || 'unspecified' }
  end

  attribute :customCoverages do |value|
    { customCoverageList: value }
  end
end
