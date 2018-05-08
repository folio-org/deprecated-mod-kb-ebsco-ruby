# frozen_string_literal: true

class PackagesRepository
  attr_reader :vendor_id, :package_id, :base_url, :headers

  def initialize(config:)
    @config = config
    @base_url = "#{rmapi_url}/rm/rmaccounts/#{config.customer_id}"

    @headers = {
      'X-Api-Key': config.api_key,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  end

  # CRUD Operations
  def find!(id)
    request do
      # binding.pry
      vendor_id, package_id = id.split('-')
      status, body = rmapi(:get, "/vendors/#{vendor_id}/packages/#{package_id}")
      Result.new(data: to_package(body), status: status, included: body[:included])
    end
  end

  def create!(attrs)
    request do
      payload = attrs.to_hash.deep_symbolize_keys
      payload[:packageName] = payload.delete(:name)
      package_validation = Validation::CustomPackageParameters.new(payload)
      fail ValidationError, package_validation unless package_validation.valid?

      content_type_enum = {
        aggregatedfulltext: 1,
        abstractandindex: 2,
        ebook: 3,
        ejournal: 4,
        print: 5,
        unknown: 6,
        onlinereference: 7
      }
      payload[:contentType] = content_type_enum[payload[:contentType]&.downcase&.to_sym] || 6

      vendor_id = Provider.configure(@config).provider_id
      create_status, create_body = rmapi(:post, "/vendors/#{vendor_id}/packages/", json: payload)

      if create_status.success?
        package_id = create_body[:package_id]
        status, body = rmapi(:get, "/vendors/#{vendor_id}/packages/#{package_id}")
        Result.new(data: to_package(body), status: status)
      else
        Result.new(status: create_status, data: nil)
      end
    end
  end

  def update!(id, attrs)
    request do
      package_validation = Validation::PackageParameters.new(attrs)
      fail ValidationError, package_validation unless package_validation.valid?

      vendor_id, package_id = id.split('-')

      payload = attrs.to_hash.deep_symbolize_keys
      payload[:allowEbscoToAddTitles] = payload.delete(:allowKbToAddTitles)
      payload[:packageName] = payload.delete(:name)
      payload[:isHidden] = payload.dig(:visibilityData, :isHidden)
      payload.delete(:visibilityData)
      content_type_enum = {
        aggregatedfulltext: 1,
        abstractandindex: 2,
        ebook: 3,
        ejournal: 4,
        print: 5,
        unknown: 6,
        onlinereference: 7
      }
      payload[:contentType] = content_type_enum[payload[:contentType]&.downcase&.to_sym] || 6

      rmapi(:put, "/vendors/#{vendor_id}/packages/#{package_id}", json: payload)

      status, body = rmapi(:get, "/vendors/#{vendor_id}/packages/#{package_id}")
      Result.new(data: to_package(body), status: status)
    end
  end

  def destroy!(id)
    request do
      package = find!(id).data
      package_validation = Validation::PackageDestroyParameters.new(package)
      fail ValidationError, package_validation unless package_validation.valid?

      vendor_id, package_id = id.split('-')
      status, _no_content = rmapi(:put, "/vendors/#{vendor_id}/packages/#{package_id}", json: { isSelected: false })

      Result.new(data: {}, status: status)
    end
  end

  def where!(params)
    request do
      if params[:filter]
        fail BadRequest, 'Invalid filter parameter' unless params[:filter].respond_to?(:dig)
        if params.dig(:filter, :custom)
          # The 'custom' filter option is unique in that
          # it is not passed through to RMAPI.  Instead,
          # we have to poll for packages until all are consumed and
          # then apply the filtering here (for now).  This
          # will be extremely inefficient, but we've accepted that.
          # Presumably an API enhancement will come at some point.
          #
          # TODO: remove mutation. params sent to rmapi should be completely
          # mapped from scratch every time, not a munge of controller params
          # (cowboyd 5/3/2018)
          params[:filter].delete(:custom)

          return custom_packages!(params)
        end
      end

      path = params.fetch(:vendor_id, nil) ? "/vendors/#{params[:vendor_id]}/packages" : '/packages'
      status, body = rmapi(:get, path, params: query_params(params))
      Result.new(
        data: body[:packages_list]&.map { |hash| to_package hash },
        included: body[:included],
        status: status,
        meta: { totalResults: body[:total_results] }
      )
    end
  end

  def custom_packages!(params)
    # We need to essentially run the logic in `all!`
    # repeatedly here until all pages of packages are exhausted.
    # Maximum page size is 100.

    path = params.fetch(:vendor_id, nil) ? "/vendors/#{params[:vendor_id]}/packages" : '/packages'

    custom_packages = []

    params = query_params(params).merge(count: 100, offset: 1)
    status = nil
    body = {}
    loop do
      status, body = rmapi(:get, path, params: params)
      Result.new(status: status, message: 'Failed to fetch custom packages') unless status.success?
      packages = body[:packages_list].map { |hash| to_package(hash) }

      # If we hit an empty page we've exhausted all packages
      break if packages.empty?

      custom_packages.concat(packages.select(&:is_custom))
      params[:offset] = params[:offset] + 1
    end

    Result.new(
      data: custom_packages,
      status: status,
      meta: { totalResults: custom_packages.length }
    )
  end

  private

  # superclass for repository errors
  class RepositoryError < StandardError; end

  # the request can't be made because something is wrong with it
  class BadRequest < RepositoryError; end

  # the request was made, but it failed
  class RequestError < RepositoryError
    attr_reader :result
    def initialize(result)
      super result.message
      @result = result
    end
  end

  # there was a problem with the parameters / body passed
  # to the request
  class ValidationError < RepositoryError
    attr_reader :validation
    def initialize(validation)
      super('bad request')
      @validation = validation
    end
  end

  # TODO: split into Success and Error subclasses
  class Result
    attr_reader :data, :meta, :status, :message, :included

    def initialize(data:, status:, meta: {}, message: '', included: nil)
      @data = data
      @meta = meta
      @status = status
      @message = message
      @included = included
    end

    def return!
      fail RequestError, self unless success?
      self
    end

    delegate :success?, to: :status
  end

  def rmapi(verb, fragment, **options)
    response = HTTP.headers(headers).request(verb, "#{base_url}#{fragment}", options)
    [response.status, normalize_response_body(response)]
  end

  def rmapi_url
    Rails.application.config.rmapi_base_url
  end

  def normalize_response_body(response)
    body = response.body.to_s
    if body.length.positive?
      JSON.parse(response.body.to_s)
          .deep_transform_keys { |key| key.underscore.to_sym }
    else
      {}
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def query_params(params)
    mapping = {
      search: -> { params.fetch(:q, nil) },
      offset: -> { params.fetch(:page, 1) || 1 },
      count: -> { params.fetch(:count, 25) },
      orderby: lambda do
        case params.fetch(:sort, nil)
        when 'relevance'
          'relevance'
        when 'name'
          'packagename'
        else
          params.fetch(:q, nil) ? 'relevance' : 'packagename'
        end
      end,
      selection: lambda do
        case params.dig(:filter, :selected)
        when 'true'
          'selected'
        when 'false'
          'notselected'
        when 'ebsco'
          'orderedthroughebsco'
        else
          'all'
        end
      end,
      contenttype: -> { params.dig(:filter, :type) || 'all' }
    }

    params.delete(:include) if params[:include]

    Hash[mapping.map { |rmapi_key, value_transform| [rmapi_key, value_transform.call] }]
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def to_package(hash)
    Package.new(hash) do |package|
      package.instance_variable_set :@resources, Resource.configure(@config)
      package.instance_variable_set :@vendors, Vendor.configure(@config)
      package.instance_variable_set :@providers, Provider.configure(@config)

      package.allow_kb_to_add_titles = hash[:allow_ebsco_to_add_titles]
      package.name = hash[:package_name]
    end
  end

  def request
    yield.return!
  end
end
