# frozen_string_literal: true

class Provider < RmApiResource
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

  def update(params)
    byebug
  end

  def find_packages(**params)
    Package.configure(config).find_by_vendor(vendor_id: id, **params)
  end

  def packages
    find_packages.packagesList.to_a
  end
end
