# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class ResourceCreateParameters
    include ActiveModel::Validations

    attr_accessor :titleName, :pubType, :packageId

    validates :titleName, presence: true
    validates :pubType, presence: true
    validates :packageId, presence: true

    validates :titleName, length: { maximum: 400 }

    def initialize(params = {})
      @titleName = params[:titleName]
      @pubType = params[:pubType]
      @packageId = params[:packageId]
    end
  end
end

# rubocop:enable Naming/VariableName
