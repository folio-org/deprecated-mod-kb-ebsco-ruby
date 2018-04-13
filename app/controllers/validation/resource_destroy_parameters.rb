# frozen_string_literal: true

module Validation
  class ResourceDestroyParameters
    include ActiveModel::Validations

    validate :resource_deletable?

    def resource_deletable?
      # Resource can be deleted only if its custom
      # Check for that
      errors.add(:resource, 'cannot be deleted') unless
        @resource.isTitleCustom
    end

    def initialize(resource)
      @resource = resource
    end
  end
end
