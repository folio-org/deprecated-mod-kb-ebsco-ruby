# frozen_string_literal: true

class Provider < RmApiResource
  request_body_type :json

  get :all, '/vendors'
  get :find, '/vendors/:id'
  put :update, '/vendors/:id'

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

  def self.provider_id
    provider = all(q: config.customer_id)
    provider[:vendors].items.first.vendorId
  end

  def find_packages(**params)
    PackagesRepository.new(config: config).where! params.merge(vendor_id: id)
  end

  def packages
    find_packages.data
  end

  def update(params)
    merge_fields(params)
    save!
  end

  def save!
    attributes = update_fields
    self.class.update(
      id: vendorId,
      vendorToken: attributes[:vendorToken],
      proxy: attributes[:proxy]
    )
    refresh!
  end

  private

  def refresh!
    # re-fetch from RM API to surface side-effects
    saved = self.class.find(
      id: vendorId
    )
    merge_fields(saved)
  end

  def merge_fields(new_values)
    update_fields.deep_merge(new_values.to_hash).each do |k, v|
      send("#{k}=".to_sym, v)
    end
  end

  def update_fields
    to_hash.with_indifferent_access.slice(
      :vendorToken,
      :proxy
    )
  end
end
