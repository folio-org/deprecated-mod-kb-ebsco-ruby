# frozen_string_literal: true

class Title < RmApiResource
  get :all, '/titles'
  get :find, '/titles/:id'
  put :save, '/titles/:id'

  before_request do |name, request|
    if name == :all
      filters = request.get_params.delete(:filter) || {}

      unless filters.is_a?(ActionController::Parameters) || filters.is_a?(Hash)
        fail ActionController::BadRequest, 'Invalid filter parameter'
      end

      querykeys = filters.keys & %w[name isxn subject publisher]

      unless querykeys.size <= 1
        fail ActionController::BadRequest, 'Conflicting filter parameters'
      end

      titlename = filters[:name]
      isxn = filters[:isxn]
      subject = filters[:subject]
      publisher = filters[:publisher]
      query = request.get_params.delete(:q)

      if query && querykeys.size == 1
        fail ActionController::BadRequest, 'Conflicting query parameters'
      end

      if query
        request.get_params[:search] = query
        request.get_params[:searchfield] = 'titlename'
      elsif titlename
        request.get_params[:search] = titlename
        request.get_params[:searchfield] = 'titlename'
      elsif isxn
        request.get_params[:search] = isxn
        request.get_params[:searchfield] = 'isxn'
      elsif subject
        request.get_params[:search] = subject
        request.get_params[:searchfield] = 'subject'
      elsif publisher
        request.get_params[:search] = publisher
        request.get_params[:searchfield] = 'publisher'
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

      request.get_params[:resourcetype] = filters[:type] || 'all'

      sort = request.get_params.delete(:sort)
      request.get_params[:orderby] =
        if sort == 'relevance'
          'relevance'
        elsif sort == 'name'
          'titlename'
        else
          request.get_params[:search] ? 'relevance' : 'titlename'
        end

      request.get_params[:count] ||= 25
      request.get_params[:offset] = request.get_params.delete(:page) || 1
    end
  end

  def id
    titleId
  end

  def resources
    title_attrs = to_hash
    resources_list = title_attrs.delete('customerResourcesList').to_a
    resources_list.map do |resource|
      title_attrs['customerResourcesList'] = [resource]
      Resource.new(title_attrs)
    end
  end

  # RM API creates titles as a side-effect of creating resources, so
  # we actually create a resource here, but then return the resulting
  # title that was also created
  def self.create_title(params)
    package_id = params[:packageId]
    create_params = params.to_hash.except(:packageId)
    rm_api_create = { vendor_id: provider_id, package_id: package_id }.merge(create_params)
    resource_response = Resource.configure(config).create rm_api_create
    find resource_response[:titleId]
  end

  def self.provider_id
    Provider.configure(config).provider_id
  end
end
