# frozen_string_literal: true

module Validation
  class PackageDestroyParameters
    include ActiveModel::Validations

    validate :package_deletable?

    def package_deletable?
      # Package can be deleted only if its custom
      # Check for that
      errors.add(:package, 'cannot be deleted') unless
        @package.is_custom
    end

    def initialize(package)
      @package = package
    end
  end
end
