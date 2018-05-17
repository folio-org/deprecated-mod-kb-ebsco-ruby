# frozen_string_literal: true

module Validation
  class RootProxyParameters
    include ActiveModel::Validations

    attr_accessor :root_proxy_id,
                  :proxy_types_list

    validates :root_proxy_id, presence: true
    validate :id_valid?

    def id_valid?
      errors.add(:id, ':Invalid proxy') unless
        root_proxy_valid
    end

    def root_proxy_valid
      # root proxy passed in should be part of the
      # customer's root proxy list
      is_valid = false
      proxy_types_list.each do |proxy_type|
        if proxy_type.id == root_proxy_id
          is_valid = true
          break
        end
      end
      is_valid
    end

    def initialize(root_proxy_id, proxy_types_list)
      @root_proxy_id = root_proxy_id
      @proxy_types_list = proxy_types_list
    end
  end
end
