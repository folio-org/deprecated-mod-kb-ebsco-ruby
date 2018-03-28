# frozen_string_literal: true

module Validation
  class RootProxyParameters
    include ActiveModel::Validations

    attr_accessor :root_proxy_id,
                  :id,
                  :root_proxies_list

    validates :id, presence: true
    validate :ids_match?
    validate :id_valid?

    def ids_match?
      # root_proxy_id is what is passed in the url
      # id is what is passed in the payload
      errors.add(:id, ':ids in url and body should match') unless
        (id.is_a? String) && (id == root_proxy_id)
    end

    def id_valid?
      errors.add(:id, ':Invalid proxy') unless
        root_proxy_valid
    end

    def root_proxy_valid
      # root proxy passed in should be part of the
      # customer's root proxy list
      is_valid = false
      root_proxies_list.each do |root_proxy|
        if root_proxy.id == root_proxy_id
          is_valid = true
          break
        end
      end
      is_valid
    end

    def initialize(params, root_proxy_id, root_proxies_list)
      @root_proxy_id = root_proxy_id
      @id = params['id']
      @root_proxies_list = root_proxies_list
    end
  end
end
