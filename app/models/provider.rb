# frozen_string_literal: true

class Provider < RmApiResource
  request_body_type :json

  get :all, '/vendors'
  get :find, '/vendors/:id'
  put :update, '/vendors/:vendor_id'

  before_request do |name, request|
    if name == :all
      request.get_params[:search] = request.get_params.delete(:q)

      sort = request.get_params.delete(:sort)
      request.get_params[:orderby] =
        if sort == 'relevance'
          'relevance'
        elsif sort == 'name'
          'vendorname'
        else
          request.get_params[:search] ? 'relevance' : 'vendorname'
        end

      request.get_params[:count] ||= 25
      request.get_params[:offset] = request.get_params[:page] || 1
      request.get_params.delete(:page)
    end
  end

  def id
    vendorId
  end

  def find_packages(**params)
    Package.configure(config).find_by_vendor(vendor_id: id, **params)
  end

  def packages
    find_packages.packagesList.to_a
  end

  def update(params)
    merge_fields!(params)
    save!
  end

  def save! # rubocop:disable Metrics/AbcSize
    attributes = update_fields
    self.class.update(
      value: attributes[:vendorToken][:value]
    )
    refresh!
  end

  private

  def refresh!
    # re-fetch from RM API to surface side-effects
    saved = self.class.find(
      vendor_id: resource.vendorId
    )
    merge_fields!(saved)
  end

  def merge_fields(new_values)
    update_fields.deep_merge(new_values.to_hash).each do |k, v|
      send("#{k}=".to_sym, v)
    end
  end

  def update_fields
    resource.to_hash.with_indifferent_access.slice(
      :vendorToken
    )
  end
end
