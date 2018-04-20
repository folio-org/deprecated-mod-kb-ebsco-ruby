# frozen_string_literal: true

class Package < RmApiResource
  request_body_type :json

  get :all, '/packages'
  get :find, '/vendors/:vendor_id/packages/:package_id'
  get :find_by_vendor, '/vendors/:vendor_id/packages'
  put :update, '/vendors/:vendor_id/packages/:package_id'
  post :create, '/vendors/:vendor_id/packages/'

  before_request do |name, request|
    if %i[all find_by_vendor].include?(name)
      filters = request.get_params.delete(:filter) || {}

      unless filters.is_a?(ActionController::Parameters) || filters.is_a?(Hash)
        raise ActionController::BadRequest, 'Invalid filter parameter'
      end

      request.get_params[:selection] =
        if filters[:selected] == 'true'
          'selected'
        elsif filters[:selected] == 'false'
          'notselected'
        elsif filters[:selected] == 'ebsco'
          'orderedthroughebsco'
        else
          'all'
        end

      request.get_params[:search] = request.get_params.delete(:q)
      request.get_params[:contenttype] = filters[:type] || 'all'

      sort = request.get_params.delete(:sort)
      request.get_params[:orderby] =
        if sort == 'relevance'
          'relevance'
        elsif sort == 'name'
          'packagename'
        else
          request.get_params[:search] ? 'relevance' : 'packagename'
        end

      request.get_params[:orderby] ||=
        (request.get_params[:search] ? 'relevance' : 'packagename')
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

  def provider
    Provider.configure(config).find(vendorId)
  end

  def resources
    find_resources.titles.to_a
  end

  def find_resources(**params)
    Resource.configure(config).find_by_package(
      vendor_id: vendorId,
      package_id: packageId,
      **params
    )
  end

  def self.create_package(params)
    rm_api_create = { vendor_id: provider_id }.merge(params)
    # RM API gives only packageId after the creation of a package
    # since our UI needs more, we make a GET request to RM API for the
    # package we just created and give that as response
    package_response = create rm_api_create
    find(
      vendor_id: provider_id,
      package_id: package_response[:packageId]
    )
  end

  def self.provider_id
    Provider.configure(config).provider_id
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

    self.class.update(
      vendor_id: vendorId,
      package_id: packageId,
      isSelected: attributes[:isSelected],
      allowEbscoToAddTitles: attributes[:allowEbscoToAddTitles],
      isHidden: attributes[:visibilityData][:isHidden],
      customCoverage: attributes[:customCoverage],
      packageName: attributes[:packageName],
      contentType: attributes[:contentType]
    )
    refresh!
  end

  def delete
    self.class.update(
      vendor_id: vendorId,
      package_id: packageId,
      isSelected: false
    )
  end

  private

  def refresh!
    # re-fetch from RM API to surface side-effects
    saved_package = self.class.find(
      vendor_id: vendorId,
      package_id: packageId
    )
    merge_fields(saved_package)
  end

  def merge_fields(new_values)
    update_fields.deep_merge(new_values.to_hash).each do |k, v|
      send("#{k}=".to_sym, v)
    end
  end

  def update_fields
    if isCustom?
      to_hash.with_indifferent_access.slice(
        :isSelected,
        :allowEbscoToAddTitles,
        :visibilityData,
        :customCoverage,
        :packageName,
        :contentType
      )
    else
      to_hash.with_indifferent_access.slice(
        :isSelected,
        :allowEbscoToAddTitles,
        :visibilityData,
        :customCoverage
      )
    end
  end
end
