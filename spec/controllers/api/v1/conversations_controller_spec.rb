# spec/controllers/api/v1/conversations_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, type: :controller do
  let!(:api_user) { create(:user, :client, location: 'POINT(2.0 2.0)', email: 'client@someone.com', name: 'client') }
  let!(:other_user) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'provider@someone.com', name: 'provider') }

  let!(:conversation) { create(:conversation, sender: api_user, recipient: other_user) }

  before do
    allow(controller).to receive(:authenticate_from_token!).and_return(true)
    controller.instance_variable_set(:@api_user, api_user) # or provider based on the test
  end

  describe "GET #index" do
    it "returns a list of conversations" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['conversations']).not_to be_empty
    end
  end

  describe "POST #create" do
    context "when a conversation doesn't exist between users" do
      it "creates a new conversation" do
        post :create, params: { recipient_id: other_user.id }
        expect(response).to have_http_status(:created)
      end
    end

    context "when a conversation already exists between users" do
      before do
        conversation # Create the conversation by calling it
      end

      it "does not create a new conversation" do
        expect {
          post :create, params: { recipient_id: other_user.id }
        }.to change(Conversation, :count).by(0)
      end
    end
  end

  describe "DELETE #destroy" do
    it "archives the conversation" do
      delete :destroy, params: { id: conversation.id }
      expect(response).to have_http_status(:ok)
      expect(Conversation.find(conversation.id).archived).to eq(true)
    end
  end

  describe "GET #unread_messages_count" do
    let(:message) { create(:message, conversation: conversation, user: other_user, read: false) }

    it "returns the count of unread messages" do
      message # Create the message by calling it
      get :unread_messages_count
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['unread_messages_count']).to eq(1)
    end
  end
end
