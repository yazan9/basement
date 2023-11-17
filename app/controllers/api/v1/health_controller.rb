class Api::V1::HealthController < ApplicationController
  def index
    #QueueOutgoingMessageWorker.perform_async
    render json: { message: 'Healthy' }, status: :ok
  end
end