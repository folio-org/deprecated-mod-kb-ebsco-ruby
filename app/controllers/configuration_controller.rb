require 'okapi'

class ConfigurationController < ApplicationController
  include JSONAPI::ActsAsResourceController

  def context
    {okapi: okapi}
  end

  def transaction
     lambda { |&block|
         block.yield
      }
  end

  def rollback
      lambda {
        # fail StandardError, 'rollback'
      }
  end

end
