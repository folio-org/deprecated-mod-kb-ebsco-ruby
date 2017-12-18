class CustomerResource < RmApiResource

  ARRAY_FIELDS = [
    :contributorsList,
    :identifiersList,
    :subjectsList,
    :customerResourcesList,
    :managedCoverageList,
    :customCoverageList,
  ]

  request_body_type :json

  get :find, "/#customer_id/vendors/:vendor_id/packages/:package_id/titles/:title_id", array: ARRAY_FIELDS
  get :find_by_package, "/#customer_id/vendors/:vendor_id/packages/:package_id/titles", array: ARRAY_FIELDS
  put :update, "/#customer_id/vendors/:vendor_id/packages/:package_id/titles/:title_id"


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

  # Relationships
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

    # Coverage date order matters to RMAPI, so make sure
    # these are sorted before sending them off.
    sorted_coverage = attributes[:customCoverageList].sort_by do |coverage|
      Date.strptime(coverage[:beginCoverage], '%Y-%m-%d')
    end.reverse

    self.class.update({
      vendor_id: resource.vendorId,
      package_id: resource.packageId,
      title_id: titleId,
      isSelected: attributes[:isSelected],
      isHidden: attributes[:visibilityData][:isHidden],
      customCoverageList: sorted_coverage,
      customEmbargoPeriod: attributes[:customEmbargoPeriod]
    })

    # re-fetch from RM API to surface side-effects
    saved = self.class.find(vendor_id: resource.vendorId, package_id: resource.packageId, title_id: titleId)
    merge_fields(saved.customerResourcesList.first)
  end

  private

  def merge_fields(new_values)
    update_fields.deep_merge(new_values.to_hash).each do |k,v|
      self.resource.send("#{k}=".to_sym, v)
    end
  end

  def update_fields
    whitelist = [
      :isSelected,
      :visibilityData,
      :customCoverageList,
      :customEmbargoPeriod
    ]

    resource.to_hash.with_indifferent_access.slice(*whitelist)
  end
end
