class CustomerResourcesController < ApplicationController
  before_action :configure_resource

  def show
    begin
      vendor_id, package_id, title_id = params[:id].split('-')
      customer_resource = CustomerResource.find(
        vendor_id: vendor_id,
        package_id: package_id,
        title_id: title_id
      )
      render jsonapi: customer_resource,
             include: params[:include]
    rescue Flexirest::HTTPClientException, Flexirest::HTTPServerException, Flexirest::HTTPNotFoundClientException => e
      render jsonapi_errors: e.result.Errors.to_a.map{ |err| {"title": err.to_hash['Message']} },
             status: e.status
    end
  end

  def update
    begin
      vendor_id, package_id, title_id = params[:id].split('-')
      customer_resource = CustomerResource.find(
        vendor_id: vendor_id,
        package_id: package_id,
        title_id: title_id
      )
      customer_resource.update(
        customer_resource_params.merge(
          vendor_id: vendor_id,
          package_id: package_id,
          title_id: title_id
        )
      )
      render status: :no_content
    rescue Flexirest::HTTPClientException, Flexirest::HTTPServerException, Flexirest::HTTPNotFoundClientException => e
      render jsonapi_errors: e.result.Errors.to_a.map{ |err| {"title": err.to_hash['Message']} },
             status: e.status
    end
  end

  private

  def customer_resource_params
    params.permit(
      :isSelected,
      :isHidden,
      {:customCoverages => [:beginCoverage, :endCoverage]},
      :coverageStatement,
      :customEmbargoPeriod => {}
    )
  end

  def configure_resource
    CustomerResource.verbose!
    CustomerResource.configure(config)
  end
end
