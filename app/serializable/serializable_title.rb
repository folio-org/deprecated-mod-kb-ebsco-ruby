class SerializableTitle < SerializableResource
  type 'titles'

  has_many :customer_resources

  attributes :name,
             :description,
             :publisherName,
             :isTitleCustom,
             :isPeerReviewed

  attribute :name do
    @object.titleName
  end

  attribute :contributors do
    @object.contributorsList
  end

  attribute :subjects do
    @object.subjectsList
  end


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

    @object.identifiersList.map do |identifier|
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

    type_key = @object.pubType.downcase.to_sym
    publication_types[type_key] || @object.pubType
  end
end
