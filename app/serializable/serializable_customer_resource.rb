class SerializableCustomerResource < SerializableResource
  type 'customerResources'

  attributes :contributors,
             :coverage_statement,
             :custom_coverages,
             :custom_embargo_period,
             :description,
             :is_peer_reviewed,
             :is_selected,
             :managed_coverages,
             :managed_embargo_period,
             :name,
             :package_id,
             :package_name,
             :publisher_name,
             :subjects,
             :title_id,
             :url,
             :vendor_id,
             :vendor_name,
             :visibility_data

  attribute :identifiers do
    types = {
      0 => 'ISSN',
      1 => 'ISBN',
      2 => 'TSDID',
      3 => 'SPID',
      4 => 'EjsJournalID',
      5 => 'NewsbankID',
      6 => 'ZDBID',
      7 => 'EPBookID',
      8 => 'Mid',
      9 => 'BHM'
    }

    subtypes = {
      0 => 'Empty',
      1 => 'Print',
      2 => 'Online',
      3 => 'Preceding',
      4 => 'Succeeding',
      5 => 'Regional',
      6 => 'Linking',
      7 => 'Invalid'
    }

    @object.identifiers.map do |identifier|
      {
        id: identifier['id'],
        type: types[identifier['type']] || '',
        subtype: subtypes[identifier['subtype']] || ''
      }
    end
  end

  attribute :publication_type do
    publication_types = {
      all: 'All',
      audiobook: 'Audiobook',
      book: 'Book',
      bookseries: 'Book Series',
      database: 'Database',
      journal: 'Journal',
      newsletter: 'Newsletter',
      newspaper: 'Newspaper',
      proceedings: 'Proceedings',
      report: 'Report',
      streamingaudio: 'Streaming Audio',
      streamingvideo: 'Streaming Video',
      thesisdissertation: 'Thesis & Dissertation',
      website: 'Website',
      unspecified: 'Unspecified'
    }

    type_key = @object.publication_type.downcase
    publication_types[type_key] || @object.publication_type
  end
end
