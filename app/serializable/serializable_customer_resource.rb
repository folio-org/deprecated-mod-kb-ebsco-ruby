# frozen_string_literal: true

class SerializableCustomerResource < SerializableResource
  type 'customerResources'

  has_one :vendor
  has_one :provider
  has_one :title
  has_one :package

  # Title Attributes
  attributes :description,
             :edition,
             :isPeerReviewed,
             :isTitleCustom,
             :publisherName,
             :titleId

  attribute :contributors do
    @object.contributorsList || []
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

    if @object.identifiersList
      @object.identifiersList.map do |identifier|
        {
          id: identifier['id'],
          type: types[identifier['type']] || '',
          subtype: subtypes[identifier['subtype']] || ''
        }
      end
    else
      []
    end
  end
  attribute :name do
    @object.titleName
  end
  attribute :publicationType do
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
  attribute :subjects do
    @object.subjectsList || []
  end

  # CustomerResource Attributes
  attribute :coverageStatement do
    @object.resource.coverageStatement
  end
  attribute :customEmbargoPeriod do
    @object.resource.customEmbargoPeriod
  end
  attribute :isPackageCustom do
    @object.resource.isPackageCustom
  end
  attribute :isSelected do
    @object.resource.isSelected
  end
  attribute :isTokenNeeded do
    @object.resource.isTokenNeeded
  end
  attribute :locationId do
    @object.resource.locationId
  end
  attribute :managedEmbargoPeriod do
    @object.resource.managedEmbargoPeriod
  end
  attribute :packageId do
    "#{@object.resource.vendorId}-#{@object.resource.packageId}"
  end
  attribute :packageName do
    @object.resource.packageName
  end
  attribute :url do
    @object.resource.url
  end
  attribute :vendorId do
    @object.resource.vendorId
  end
  attribute :vendorName do
    @object.resource.vendorName
  end
  attribute :providerId do
    @object.resource.vendorId
  end
  attribute :providerName do
    @object.resource.vendorName
  end
  attribute :visibilityData do
    visibility = @object.resource.visibilityData
    if visibility[:isHidden]
      visibility[:reason] =
        visibility[:reason] == 'Hidden by EP' ? 'Set by system' : ''
    end
    visibility
  end
  attribute :managedCoverages do
    @object.resource.managedCoverageList
  end
  attribute :customCoverages do
    @object.resource.customCoverageList
  end
end
