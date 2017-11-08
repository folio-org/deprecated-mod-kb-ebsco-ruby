class CustomerResource
  def initialize(title_data:, customer_resource_data: nil)
    @attrs = title_data
    @customer_resource_data = customer_resource_data || @attrs['customerResourcesList'].first
  end

  def id
    "#{vendor_id}-#{package_id}-#{title_id}"
  end

  def title_id
    @attrs['titleId']
  end

  def vendor_id
    @customer_resource_data['vendorId']
  end

  def package_id
    @customer_resource_data['packageId']
  end

  def name
    @attrs['titleName']
  end

  def vendor_name
    @customer_resource_data['vendorName']
  end

  def package_name
    @customer_resource_data['packageName']
  end

  def is_selected
    @customer_resource_data['isSelected']
  end

  def selected_count
    @attrs['selectedCount']
  end

  def title_count
    @attrs['titleCount']
  end

  def contributors
    @attrs['contributorsList']
  end

  def coverage_statement
    @customer_resource_data['coverageStatement']
  end

  def custom_coverages
    @customer_resource_data['customCoverageList']
  end

  def custom_embargo_period
    @customer_resource_data['customEmbargoPeriod']
  end

  def description
    @attrs['description']
  end

  def identifiers
    @attrs['identifiersList']
  end

  def is_peer_reviewed
    @attrs['isPeerReviewed']
  end

  def managed_coverages
    @customer_resource_data['managedCoverageList']
  end

  def managed_embargo_period
    @customer_resource_data['managedEmbargoPeriod']
  end

  def publication_type
    @attrs['pubType']
  end

  def publisher_name
    @attrs['publisherName']
  end

  def subjects
    @attrs['subjectsList']
  end

  def url
    @customer_resource_data['url']
  end

  def visibility_data
    @customer_resource_data['visibilityData']
  end
end
