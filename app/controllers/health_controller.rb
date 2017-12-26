# frozen_string_literal: true

class HealthController < ActionController::Base
  def index
    render json: '', status: :ok
  end
end
