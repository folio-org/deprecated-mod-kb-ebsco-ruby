class CustomerResource < RmApiResource
  request_body_type :json
  get :find, "/#customer_id/vendors/:vendor_id/packages/:package_id/titles/:title_id"
  get :find_by_package, "/#customer_id/vendors/:vendor_id/packages/:package_id/titles"
  put :update, "/#customer_id/vendors/:vendor_id/packages/:package_id/titles/:title_id"

  before_request do |name, request|
    if name == :find_by_package
      request.get_params[:search] = ''
      request.get_params[:searchfield] = 'titlename'
      request.get_params[:orderby] = 'titlename'
      request.get_params[:count] ||= 25
      request.get_params[:offset] ||= 1
    elsif name == :update
      resource = request.post_params[:customerResourcesList].to_a.first
      request.post_params = {
       isSelected: request.post_params["isSelected"] || resource.isSelected,
       isHidden: request.post_params["isHidden"] || resource.visibilityData.isHidden,
       customCoverageList: request.post_params["customCoverages"] || resource.customCoverages.to_a,
       coverageStatement: request.post_params["coverageStatement"] || resource.coverageStatement,
       customEmbargoPeriod: request.post_params["customEmbargoPeriod"] || resource.customEmbargoPeriod,
      }
    end
  end

  def id
    "#{resource.vendorId}-#{resource.packageId}-#{titleId}"
  end

  def vendor
    Vendor.find(resource.vendorId)
  end

  def title
    Title.find(titleId)
  end

  def package
    Package.find(vendor_id: resource.vendorId, package_id: resource.packageId)
  end

  def resource
    customerResourcesList.first
  end
end
