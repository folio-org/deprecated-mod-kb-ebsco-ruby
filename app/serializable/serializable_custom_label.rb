# frozen_string_literal: true

class SerializableCustomLabel < SerializableResource
  type 'customLabel'

  # Custom Label attributes
  attributes :id,
             :display_label,
             :display_on_full_text_finder,
             :display_on_publication_finder
end
