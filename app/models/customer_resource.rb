class CustomerResource
  def initialize(attrs)
    @attrs = attrs
  end

  def id
    "#{vendor_id}-#{package_id}-#{title_id}"
  end

  def title_id
    @attrs['titleId']
  end

  def vendor_id
    @attrs['vendorId']
  end

  def package_id
    @attrs['packageId']
  end

  def package_name
    @attrs['packageName']
  end

  def is_selected
    @attrs['isSelected']
  end

  def selected_count
    @attrs['selectedCount']
  end

  def title_count
    @attrs['titleCount']
  end
end