# frozen_string_literal: true

class Vendor < RmApiResource
  get :all, '/vendors'
  get :find, '/vendors/:id'

  before_request do |name, request|
    if name == :all
      request.get_params[:search] = request.get_params.delete(:q)
      request.get_params[:orderby] ||=
        (request.get_params[:search] ? 'relevance' : 'vendorname')
      request.get_params[:count] ||= 25
      request.get_params[:offset] = request.get_params[:page] || 1
      request.get_params.delete(:page)
    end
  end

  def id
    vendorId
  end

  def find_packages(**params)
    PackagesRepository.new(config: config).where! params.merge(vendor_id: id)
  end

  def packages
    find_packages.data
  end
end
