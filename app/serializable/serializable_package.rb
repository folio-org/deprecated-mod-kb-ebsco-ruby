class SerializablePackage < SerializableResource
  type 'packages'

  has_many :customer_resources
  has_one :vendor

  attributes :vendorId,
             :packageId,
             :contentType,
             :titleCount,
             :selectedCount,
             :customCoverage,
             :isSelected,
             :vendorName

  attribute :name do
    @object.packageName
  end

  attribute :visibilityData do
    visibility = @object.visibilityData

    if visibility['isHidden']
      { isHidden: true, reason: 'All titles in this package are hidden' }
    else
      visibility
    end
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
    };

    content_type_key = @object.contentType.downcase.to_sym

    content_types[content_type_key] || @object.contentType
  end
end
