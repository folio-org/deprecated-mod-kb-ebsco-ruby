# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class ResourceAssociateParameters
    include ActiveModel::Validations

    attr_accessor :titleId, :packageId, :title, :package, :url

    validates :titleId, presence: true
    validates :packageId, presence: true

    validate :package_is_custom?
    validate :title_exists?
    validate :title_not_in_package?
    validate :url_has_valid_format?, unless: -> { url.nil? }

    def package_is_custom?
      errors.add(:PackageId, 'Cannot associate Title with a managed Package') unless
        @package.is_custom
    end

    def title_exists?
      errors.add(:TitleId, 'Title Not Found') unless @title
    end

    def package_exists?
      errors.add(:PackageId, 'Package Not Found') unless @package
    end

    def title_not_in_package?
      errors.add(:Base, 'Package already associated with Title') if
                  package.resources.map(&:titleId).include?(@titleId)
    end

    def url_has_valid_format?
      errors.add(:url, 'has invalid format') unless
        url.downcase.start_with?('https://', 'http://')
    end

    def initialize(params = {})
      @packageId = params[:packageId]
      @titleId = params[:titleId]
      @package = params[:package]
      @title = params[:title]
      @url = params[:url]
    end
  end
end

# rubocop:enable Naming/VariableName
