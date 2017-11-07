class Package
  def initialize(data:, titles: [])
    @attrs = data
    @titles = titles
  end

  def id
    "#{vendor_id}-#{package_id}"
  end

  def package_id
    @attrs['packageId']
  end

  def vendor_id
    @attrs['vendorId']
  end

  def name
    @attrs['packageName']
  end

  def title_count
    @attrs['titleCount']
  end

  def selected_count
    @attrs['selectedCount']
  end

  def custom_coverage
    @attrs['customCoverage']
  end

  def visibility_data
    visibility = @attrs['visibilityData']

    if visibility['isHidden']
      { isHidden: true, reason: 'All titles in this package are hidden' }
    else
      visibility
    end
  end

  def is_selected
    @attrs['isSelected']
  end

  def vendor_name
    @attrs['vendorName']
  end

  def customer_resources
    @titles.map do |title|
      CustomerResource.new(title.customerResourcesList[0])
    end
  end

  def content_type
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

    content_type_key = @attrs['contentType'].downcase.to_sym

    content_types[content_type_key] || @attrs['contentType']
  end
end
