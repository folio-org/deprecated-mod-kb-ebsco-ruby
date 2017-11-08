class Vendor < RmApiResource
  get :all, "/#customer_id/vendors"
  get :find, "/#customer_id/vendors/:id"

  before_request do |name, request|
    if name == :all
      request.get_params[:search] = request.get_params.delete(:q)
      request.get_params[:orderby] ||= (request.get_params[:search] ? 'relevance' : 'vendorname')
      request.get_params[:count] ||= 25
      request.get_params[:offset] ||= 1
    end
  end

  def id
    vendorId
  end

  def packages
    Package.find_by_vendor(vendor_id: id).packagesList.to_a
  end
end
