class Api::V1::ConversationsController < ApplicationController
  before_action :set_conversations, only: [:index, :unread_messages_count]
  before_action :set_conversation, only: [:destroy]

  include PaginationConcern

  def index
    render json: {conversations: ConversationBlueprint.render_as_hash(paginate(@conversations), current_user:@api_user), meta: pagination_status}, status: :ok
  end

  def create
    @conversations = Conversation.between(@api_user.id, params[:recipient_id])
    if @conversations.present?
      @conversation = @conversations.first
    else
      @conversation = Conversation.new(conversation_params)
    end

    if @conversation.save
      render json: @conversation, status: :created
    else
      render json: { error: @conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @conversation.archived = true

    if @conversation.save
      render json: @conversation, status: :ok
    else
      render json: { error: @conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def unread_messages_count
    total_unread_count = Message.where(conversation_id: @conversations.map(&:id))
                                .where(read: false)
                                .where.not(user_id: @api_user.id)
                                .count

    render json: { unread_messages_count: total_unread_count }, status: :ok
  end

  private

  def set_conversations
    @conversations = Conversation.includes(:sender, :recipient, :messages)
                                 .where("sender_id = ? OR recipient_id = ?", @api_user.id, @api_user.id)
  end

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def conversation_params
    params.permit(:recipient_id).merge(sender_id: @api_user.id)
  end
end
