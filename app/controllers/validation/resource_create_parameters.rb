# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class ResourceCreateParameters
    include ActiveModel::Validations

    attr_accessor :titleName, :pubType, :package_id

    validates :titleName, presence: true
    validates :pubType, presence: true
    validates :package_id, presence: true

    validates :titleName, length: { maximum: 400 }

    def initialize(params = {})
      @titleName = params[:titleName]
      @pubType = params[:pubType]
      @package_id = params[:package_id]
    end
  end
end

# rubocop:enable Naming/VariableName
