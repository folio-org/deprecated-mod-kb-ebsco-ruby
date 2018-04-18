# frozen_string_literal: true

module Validation
  class ResourceDestroyParameters
    include ActiveModel::Validations

    validate :resource_deletable?

    def resource_deletable?
      # custom or managed titles can be deleted as long
      # as the package its associated with is custom.
      # Check for that
      errors.add(:resource, 'cannot be deleted') unless
        @is_package_custom
    end

    def initialize(customer_resource_list)
      customer_resource = customer_resource_list.first
      @is_package_custom = customer_resource['isPackageCustom']
    end
  end
end
