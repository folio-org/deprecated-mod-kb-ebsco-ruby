# frozen_string_literal: true

class PackagesRepository < RmapiRepository
  def find!(id)
    vendor_id, package_id = id.split('-')

    fail RequestError.new('Package and provider id are required', 400) unless vendor_id && package_id

    status, body = request(:get, "/vendors/#{vendor_id}/packages/#{package_id}")
    Result.new(data: to_package(body), status: status, included: body[:included])
  end

  def create!(attrs)
    payload = attrs.to_hash.deep_symbolize_keys
    payload[:packageName] = payload.delete(:name)

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
    _, create_body = request(:post, "/vendors/#{vendor_id}/packages/", json: payload)

    package_id = create_body[:package_id]

    status, body = request(:get, "/vendors/#{vendor_id}/packages/#{package_id}")
    Result.new(data: to_package(body), status: status)
  end

  def update!(id, attrs)
    vendor_id, package_id = id.split('-')

    existing_package = find!(id).data

    payload = attrs.to_hash.deep_symbolize_keys
    payload[:allowEbscoToAddTitles] = payload.delete(:allowKbToAddTitles)
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
    if existing_package.is_custom
      payload[:contentType] = content_type_enum[payload[:contentType]&.downcase&.to_sym] || 6
      payload[:packageName] = payload.delete(:name)
    end

    request(:put, "/vendors/#{vendor_id}/packages/#{package_id}", json: payload)

    status, body = request(:get, "/vendors/#{vendor_id}/packages/#{package_id}")
    Result.new(data: to_package(body), status: status)
  end

  def destroy!(id)
    vendor_id, package_id = id.split('-')

    fail RequestError.new('Package and provider id are required', 400) unless vendor_id && package_id

    status, _no_content = request(:put, "/vendors/#{vendor_id}/packages/#{package_id}", json: { isSelected: false })

    Result.new(data: {}, status: status)
  end

  def where!(params)
    vendor_id = params.fetch(:vendor_id, nil)
    params[:count] = params[:count] ||= 25

    # TODO: controller?
    if params[:filter]
      fail RequestError.new('Invalid filter parameter', 400) unless params[:filter].respond_to?(:dig)
      if params.dig(:filter, :custom)
        # The 'custom' filter option is unique in that
        # it is not passed through to RMAPI.
        #
        # TODO: remove mutation. params sent to rmapi should be completely
        # mapped from scratch every time, not a munge of controller params
        # (cowboyd 5/3/2018)
        params[:filter].delete(:custom)

        # All custom packages have the same vendor_id per

        vendor_id = Provider.configure(@config).provider_id
      end
    end

    path = vendor_id ? "/vendors/#{vendor_id}/packages" : '/packages'
    status, body = request(:get, path, params: query_params(params))
    Result.new(
      data: body[:packages_list]&.map { |hash| to_package hash },
      included: body[:included],
      status: status,
      meta: { totalResults: body[:total_results] }
    )
  end

  private

  class Result
    attr_reader :data, :meta, :status, :message, :included

    def initialize(data:, status:, meta: {}, message: '', included: nil)
      @data = data
      @meta = meta
      @status = status
      @message = message
      @included = included
    end

    delegate :success?, to: :status
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
      package.instance_variable_set :@providers, Provider.configure(@config)

      package.allow_kb_to_add_titles = hash[:allow_ebsco_to_add_titles]
      package.name = hash[:package_name]
    end
  end
end
