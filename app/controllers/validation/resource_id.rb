# frozen_string_literal: true

module Validation
  class ResourceID
    include ActiveModel::Validations

    attr_accessor :vendor_id, :package_id, :title_id

    validates :vendor_id, presence: true
    validates :package_id, presence: true
    validates :title_id, presence: true

    validate :vendor_id_int?
    validate :package_id_int?
    validate :title_id_int?

    def vendor_id_int?
      errors.add(:vendor_id, ':Invalid vendor id') unless
        vendor_id.to_i != 0
    end

    def package_id_int?
      errors.add(:package_id, ':Invalid package id') unless
        package_id.to_i != 0
    end

    def title_id_int?
      errors.add(:title_id, ':Invalid title id') unless
        title_id.to_i != 0
    end

    def initialize(params = {})
      @vendor_id = params[:vendor_id]
      @package_id = params[:package_id]
      @title_id = params[:title_id]
    end
  end
end
