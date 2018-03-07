# frozen_string_literal: true

class SerializablePackage < SerializableResource
  type 'packages'

  has_many :customer_resources
  has_one :vendor
  has_one :provider

  attributes :vendorId,
             :packageId,
             :contentType,
             :titleCount,
             :selectedCount,
             :customCoverage,
             :isSelected,
             :allowKbToAddTitles,
             :vendorName

  attribute :providerId do
    @object.vendorId
  end

  attribute :providerName do
    @object.vendorName
  end

  attribute :name do
    @object.packageName
  end

  attribute :allowKbToAddTitles do
    @object.allowEbscoToAddTitles
  end

  attribute :visibilityData do
    visibility = @object.visibilityData

    if visibility[:isHidden]
      visibility[:reason] =
        visibility[:reason] == 'Hidden by EP' ? 'Set by system' : ''
    end
    visibility
  end

  attribute :contentType do
    content_types = {
      all: 'All',
      aggregatedfulltext: 'Aggregated Full Text',
      abstractandindex: 'Abstract and Index',
      ebook: 'E-Book',
      ejournal: 'E-Journal',
      print: 'Print',
      unknown: 'Unknown',
      onlinereference: 'Online Reference'
    }

    content_type_key = @object.contentType.downcase.to_sym

    content_types[content_type_key] || @object.contentType
  end
end
