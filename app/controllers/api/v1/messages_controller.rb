class Api::V1::MessagesController < ApplicationController
  before_action :set_conversation
  before_action :set_messages_for_conversation, only: [:index]
  before_action :set_message, only: [:destroy, :update]

  def index
    render json: @messages, status: :ok
  end

  def create
    @message = @conversation.messages.new(message_params)
    @message.user = @api_user

    if @message.save
      render json: @message, status: :created
    else
      render json: { error: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @message.update(message_params)
      render json: @message, status: :ok
    else
      render json: { error: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @message.destroy
      render json: { success: true }, status: :ok
    else
      render json: { error: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def set_messages_for_conversation
    @messages = @conversation.messages
  end

  def set_message
    @message = Message.find_by(id: params[:id], conversation_id: params[:conversation_id], user_id: @api_user.id)
  end
end
