class Title < RmApiResource
  get :all, "/#customer_id/titles"
  get :find, "/#customer_id/titles/:id"
  put :save, "/#customer_id/titles/:id"

  before_request do |name, request|
    if name == :all
      request.get_params[:search] = request.get_params.delete(:q)
      request.get_params[:searchfield] ||= 'titlename'
      request.get_params[:orderby] ||= (request.get_params[:search] ? 'relevance' : 'titlename')
      request.get_params[:count] ||= 25
      request.get_params[:offset] ||= 1
    end
  end

  def id
    titleId
  end

  def customer_resources
    title_attrs = self.to_hash
    resources_list = title_attrs.delete('customerResourcesList').to_a
    resources_list.map do |customer_resource|
      title_attrs['customerResourcesList'] = [customer_resource]
      CustomerResource.new(title_attrs)
    end
  end
end
