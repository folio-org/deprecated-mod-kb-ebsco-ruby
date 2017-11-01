class Vendor
  def initialize(attrs)
    @attrs = attrs
  end

  def id
    @attrs['vendorId']
  end

  def name
    @attrs['vendorName']
  end

  def packages_total
    @attrs['packagesTotal']
  end

  def packages_selected
    @attrs['packagesSelected']
  end
end
