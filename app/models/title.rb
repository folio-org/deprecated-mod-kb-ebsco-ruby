class Title
  def initialize(attrs)
    @attrs = attrs
  end

  def id
    @attrs['titleId']
  end

  def name
    @attrs['titleName']
  end

  def description
    @attrs['description']
  end

  def publisher_name
    @attrs['publisherName']
  end

  def is_title_custom
    @attrs['isTitleCustom']
  end

  def is_peer_reviewed
    @attrs['isPeerReviewed']
  end

  def contributors
    @attrs['contributorsList']
  end

  def subjects
    @attrs['subjectsList']
  end

  def customer_resources
    @attrs['customerResourcesList'].map do | customer_resource |
      CustomerResource.new(customer_resource)
    end
  end

  def identifiers
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

    @attrs['identifiersList'].map do | identifier |
      {
        id: identifier['id'],
        type: types[identifier['type']] || '',
        subtype: subtypes[identifier['subtype']] || ''
      }
    end
  end

  def publication_type
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
      unspecified: 'Unspecified',
    }

    type_key = @attrs['pubType'].downcase
    publication_types[type_key] || @attrs['pubType']
  end
end
