# frozen_string_literal: true

# rubocop:disable Naming/VariableName

module Validation
  class CustomPackageParameters
    include ActiveModel::Validations

    attr_accessor :packageName, :contentType

    validates :packageName, presence: true
    validates :contentType, presence: true

    def initialize(params = {})
      @packageName = params[:packageName]
      @contentType = params[:contentType]
    end
  end
end

# rubocop:enable Naming/VariableName
