# frozen_string_literal: true

class CustomLabel
  def initialize(attrs)
    @attrs = attrs
  end

  def id
    @attrs['id']
  end

  def display_label
    @attrs['displayLabel']
  end

  def display_on_full_text_finder
    @attrs['displayOnFullTextFinder']
  end

  def display_on_publication_finder
    @attrs['displayOnPublicationFinder']
  end

  def self.all
    rmapi_customer_root.all.labels.map { |attrs| new attrs }
  end

  def self.update(id, attrs)
    root = rmapi_customer_root.all
    root.update_label(id, attrs)
    # return updated custom label
    new attrs
  end

  def self.delete(id)
    root = rmapi_customer_root.all
    root.delete_label(id)
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
    configured
  end
end
