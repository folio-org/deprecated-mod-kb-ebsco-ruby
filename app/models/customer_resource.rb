class CustomerResource < RmApiResource
  get :find, "/#customer_id/vendors/:vendor_id/packages/:package_id/titles/:title_id"
  get :find_by_package, "/#customer_id/vendors/:vendor_id/packages/:package_id/titles"


  before_request do |name, request|
    if name == :find_by_package
      request.get_params[:search] = ''
      request.get_params[:searchfield] = 'titlename'
      request.get_params[:orderby] = 'titlename'
      request.get_params[:count] ||= 25
      request.get_params[:offset] ||= 1
    end
  end

  def id
    "#{resource.vendorId}-#{resource.packageId}-#{titleId}"
  end

  def vendor
    Vendor.configure(config).find(resource.vendorId)
  end

  def title
    Title.configure(config).find(titleId)
  end

  def package
    Package.configure(config).find(vendor_id: resource.vendorId, package_id: resource.packageId)
  end

  def resource
    customerResourcesList.first
  end
end
