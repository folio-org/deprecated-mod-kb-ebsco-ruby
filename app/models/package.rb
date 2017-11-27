class Package < RmApiResource
  get :all, "/#customer_id/packages"
  get :find, "/#customer_id/vendors/:vendor_id/packages/:package_id"
  get :find_by_vendor, "/#customer_id/vendors/:vendor_id/packages"

  before_request do |name, request|
    if name == :all || name == :find_by_vendor
      request.get_params[:search] = request.get_params.delete(:q)
      request.get_params[:orderby] ||= (request.get_params[:search] ? 'relevance' : 'packagename')
      request.get_params[:count] ||= 25
      request.get_params[:offset] ||= 1
    end
  end

  def id
    "#{vendorId}-#{packageId}"
  end

  def vendor
    Vendor.configure(config).find(vendorId)
  end

  def customer_resources
    CustomerResource.configure(config).find_by_package(vendor_id: vendorId, package_id: packageId).titles.to_a
  end
end
