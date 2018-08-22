# frozen_string_literal: true

class Resource < RmApiResource
  ARRAY_FIELDS = %i[
    contributorsList
    identifiersList
    subjectsList
    customerResourcesList
    managedCoverageList
    customCoverageList
  ].freeze

  request_body_type :json

  get :find, '/vendors/:vendor_id/packages/:package_id/titles/:title_id',
      array: ARRAY_FIELDS
  get :find_by_package, '/vendors/:vendor_id/packages/:package_id/titles',
      array: ARRAY_FIELDS
  put :update, '/vendors/:vendor_id/packages/:package_id/titles/:title_id'
  post :create, '/vendors/:vendor_id/packages/:package_id/titles'

  before_request do |name, request|
    if name == :find_by_package
      filters = request.get_params.delete(:filter) || {}

      unless filters.is_a?(ActionController::Parameters) || filters.is_a?(Hash)
        fail ActionController::BadRequest, 'Invalid filter parameter'
      end

      querykeys = filters.keys & %w[name isxn subject publisher]

      unless querykeys.size <= 1
        fail ActionController::BadRequest, 'Conflicting filter parameters'
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

      titlename = filters[:name]
      isxn = filters[:isxn]
      subject = filters[:subject]
      publisher = filters[:publisher]

      if titlename
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
      else
        request.get_params[:search] = ''
        request.get_params[:searchfield] = 'titlename'
      end

      sort = request.get_params.delete(:sort)
      request.get_params[:orderby] =
        if sort == 'relevance'
          'relevance'
        elsif sort == 'name'
          'titlename'
        else
          request.get_params[:search].present? ? 'relevance' : 'titlename'
        end

      request.get_params[:count] ||= 25
      request.get_params[:offset] = request.get_params[:page] || 1
      request.get_params.delete(:page)
      request.get_params.delete(:q)
    end
  end

  def id
    "#{resource.vendorId}-#{resource.packageId}-#{titleId}"
  end

  # Relationships
  def provider
    Provider.configure(config).find(resource.vendorId)
  end

  def title
    Title.configure(config).find(titleId)
  end

  def package
    PackagesRepository.new(config: config).find!(
      "#{resource.vendorId}-#{resource.packageId}"
    ).data
  end

  def resource
    customerResourcesList.first
  end

  # Instance methods
  def update(params)
    # Mimicking AR as closely as we can here. Invoking `update` on a
    # model (i.e. as an instance method) applies a hash of changes
    # to the instance and then persists that data to the store.
    merge_fields!(params)
    save!
  end

  def save!
    attributes = update_fields
    resource_attributes = resource_update_fields
    # RM API gives an error when we pass inherited as true along with updated proxy value
    # Hard code it to false; it should not affect the state of inherited that RM API maintains
    resource_attributes[:proxy][:inherited] = false

    self.class.update(
      vendor_id: resource.vendorId,
      package_id: resource.packageId,
      title_id: titleId,
      isSelected: resource_attributes[:isSelected],
      isHidden: resource_attributes[:visibilityData][:isHidden],
      customCoverageList: sorted_coverage,
      contributorsList: resource_attributes[:contributorsList],
      identifiersList: resource_attributes[:identifiersList],
      customEmbargoPeriod: resource_attributes[:customEmbargoPeriod],
      coverageStatement: resource_attributes[:coverageStatement],
      titleName: attributes[:titleName],
      pubType: attributes[:pubType],
      isPeerReviewed: attributes[:isPeerReviewed],
      publisherName: attributes[:publisherName],
      edition: attributes[:edition],
      description: attributes[:description],
      url: resource_attributes[:url],
      proxy: resource_attributes[:proxy]
    )
    refresh!
  end

  def delete
    self.class.update(
      vendor_id: resource.vendorId,
      package_id: resource.packageId,
      title_id: titleId,
      isSelected: false
    )
  end

  def self.create_resource(params)
    update(params)

    find(
      vendor_id: params[:vendor_id],
      package_id: params[:package_id],
      title_id: params[:title_id]
    )
  end

  def self.provider_id
    Provider.configure(config).provider_id
  end

  private

  def refresh!
    # re-fetch from RM API to surface side-effects
    saved = self.class.find(
      vendor_id: resource.vendorId,
      package_id: resource.packageId,
      title_id: titleId
    )
    merge_fields!(saved.resource)
  end

  def sorted_coverage
    # Coverage date order matters to RMAPI, so make sure
    # these are sorted before sending them off.
    resource_update_fields[:customCoverageList].sort_by do |coverage|
      Date.strptime(coverage[:beginCoverage], '%Y-%m-%d')
    end.reverse
  end

  def merge_fields!(new_values)
    if isTitleCustom
      update_fields.deep_merge(new_values.to_hash).each do |k, v|
        send("#{k}=".to_sym, v)
      end
    end

    resource_update_fields.deep_merge(new_values.to_hash).each do |k, v|
      resource.send("#{k}=".to_sym, v)
    end
  end

  def update_fields
    to_hash.with_indifferent_access.slice(
      :titleName,
      :pubType,
      :isPeerReviewed,
      :publisherName,
      :edition,
      :description
    )
  end

  def resource_update_fields
    if isTitleCustom
      resource.to_hash.with_indifferent_access.slice(
        :isSelected,
        :visibilityData,
        :customCoverageList,
        :contributorsList,
        :identifiersList,
        :customEmbargoPeriod,
        :coverageStatement,
        :url,
        :proxy
      )
    else
      resource.to_hash.with_indifferent_access.slice(
        :isSelected,
        :visibilityData,
        :customCoverageList,
        :customEmbargoPeriod,
        :coverageStatement,
        :proxy
      )
    end
  end
end
