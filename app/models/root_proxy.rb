# frozen_string_literal: true

class RootProxy
  def initialize(attrs, selected_root_proxy)
    @attrs = attrs
    @selected_root_proxy = selected_root_proxy
  end

  def id
    @attrs['id']
  end

  def name
    @attrs['name']
  end

  def url_mask
    @attrs['urlMask']
  end

  def selected
    if id == @selected_root_proxy['id']
      @attrs['selected'] = true
    else
      false
    end
  end

  def self.all
    rmapi_customer_root_proxies = rmapi_customer_root_proxy.all
    selected_root_proxy = rmapi_customer_root.all.proxy
    rmapi_customer_root_proxies.map { |attrs| new attrs, selected_root_proxy }
  end

  def self.update(attrs)
    root = rmapi_customer_root.all
    root.update_root_proxy_selection(attrs)
    # Get the root proxy after update
    selected_root_proxy = rmapi_customer_root.all.proxy
    # return updated selection of root proxy
    new attrs, selected_root_proxy
  end

  def self.configure(config)
    configured = Class.new(self)
    # JSONAPI blows up if we use an anonymous class because its
    # renderer needs class name
    name = self.name
    configured.send(:define_singleton_method, :name) { name }
    configured.send(:define_singleton_method, :rmapi_customer_root) do
      @rmapi_customer_root ||= RmApiCustomerRoot.configure(config)
    end
    configured.send(:define_singleton_method, :rmapi_customer_root_proxy) do
      @rmapi_customer_root_proxy ||= RmApiCustomerRootProxy.configure(config)
    end
    configured
  end
end
