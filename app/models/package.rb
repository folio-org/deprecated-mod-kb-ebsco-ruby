# frozen_string_literal: true

class Package
  include ActiveAttr::Model

  alias_attribute :vendor_id, :provider_id
  alias_attribute :vendor_name, :provider_name

  attribute :allow_kb_to_add_titles
  attribute :content_type
  attribute :custom_coverage, default: -> { CustomCoverage.new }
  attribute :is_custom
  attribute :is_selected
  attribute :name
  attribute :proxy, default: -> { Proxy.new }
  attribute :package_token
  attribute :package_id
  attribute :package_type
  attribute :provider_id
  attribute :provider_name
  attribute :selected_count
  attribute :title_count
  attribute :provider_id
  attribute :provider_name
  attribute :visibility_data, default: -> { VisibilityData.new }

  class VisibilityData
    include ActiveAttr::Model

    attribute :is_hidden
    attribute :reason
  end

  class CustomCoverage
    include ActiveAttr::Model

    attribute :begin_coverage
    attribute :end_coverage
  end

  class Proxy
    include ActiveAttr::Model

    attribute :id
    attribute :inherited
  end

  class PackageToken
    include ActiveAttr::Model

    attribute :fact_name
    attribute :help_text
    attribute :value
    attribute :prompt
  end

  def id
    "#{provider_id}-#{package_id}"
  end

  # Relationships
  def provider
    @providers.find provider_id
  end

  def resources
    find_resources.titles.to_a
  end

  def find_resources(**params)
    @resources.find_by_package(vendor_id: provider_id, package_id: package_id, **params)
  end
end
