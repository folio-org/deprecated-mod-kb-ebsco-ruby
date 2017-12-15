class Package < RmApiResource

  request_body_type :json

  get :all, "/#customer_id/packages"
  get :find, "/#customer_id/vendors/:vendor_id/packages/:package_id"
  get :find_by_vendor, "/#customer_id/vendors/:vendor_id/packages"
  put :update, "/#customer_id/vendors/:vendor_id/packages/:package_id"

  before_request do |name, request|
    if name == :all || name == :find_by_vendor
      request.get_params[:search] = request.get_params.delete(:q)
      request.get_params[:orderby] ||= (request.get_params[:search] ? 'relevance' : 'packagename')
      request.get_params[:count] ||= 25
      request.get_params[:offset] = request.get_params[:page] || 1
      request.get_params.delete(:page)
    end
  end

  def id
    "#{vendorId}-#{packageId}"
  end

  # Relationships
  def vendor
    Vendor.configure(config).find(vendorId)
  end

  def customer_resources
    CustomerResource.configure(config).find_by_package(vendor_id: vendorId, package_id: packageId).titles.to_a
  end

  # Instance methods
  def update(params)
    # Mimicking AR as closely as we can here. Invoking `update` on a
    # model (i.e. as an instance method) applies a hash of changes
    # to the instance and then persists that data to the store.

    merge_fields(params)
    save!
  end

  def save!
    attributes = update_fields

    self.class.update({
      vendor_id: vendorId,
      package_id: packageId,
      isSelected: attributes[:isSelected],
      isHidden: attributes[:visibilityData][:isHidden],
      customCoverage: attributes[:customCoverage]
    })

    # re-fetch from RM API to surface side-effects
    saved_package = self.class.find(vendor_id: vendorId, package_id: packageId)
    merge_fields(saved_package)
  end

  private

  def merge_fields(new_values)
    update_fields.deep_merge(new_values.to_hash).each do |k,v|
      self.send("#{k}=".to_sym, v)
    end
  end

  def update_fields
    whitelist = [
      :isSelected,
      :visibilityData,
      :customCoverage
    ]

    self.to_hash.with_indifferent_access.slice(*whitelist)
  end
end
