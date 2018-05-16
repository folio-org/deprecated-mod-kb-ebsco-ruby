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
             :packageId,
             :titleId,
             :proxy

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

  attribute :contributors do |value|
    { contributorsList: value }
  end

  attribute :identifiers do |values|
    types = {
      'ISSN': 0,
      'ISBN': 1,
      'TSDID': 2,
      'SPID': 3,
      'EjsJournalID': 4,
      'NewsbankID': 5,
      'ZDBID': 6,
      'EPBookID': 7,
      'Mid': 8,
      'BHM': 9
    }

    subtypes = {
      'Empty': 0,
      'Print': 1,
      'Online': 2,
      'Preceding': 3,
      'Succeeding': 4,
      'Regional': 5,
      'Linking': 6,
      'Invalid': 7
    }
    values.map do |identifier|
      type_key = identifier['type'].to_sym
      subtype_key = identifier['subtype'].to_sym
      identifier['type'] = types[type_key]
      identifier['subtype'] = subtypes[subtype_key]
    end
    { identifiersList: values }
  end
end
