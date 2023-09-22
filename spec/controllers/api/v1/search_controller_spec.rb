# spec/controllers/api/v1/search_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::SearchController, type: :controller do
  before(:all) do

  end

  describe 'GET #index' do
    context 'when missing required parameters' do
      it 'returns a bad request status' do
        get :index
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when all required parameters are present' do
      let!(:user1) { create(:user, :provider, location: 'POINT(0.0 0.0)', email: 'user1@someone.com', name: 'user1') }
      let!(:user2) { create(:user, :provider, location: 'POINT(0.1 0.1)', email: 'user2@someone.com', name: 'user2') }
      let!(:user3) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'user3@someone.com', name: 'user3') }

      it 'returns a list of users within a radius' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '16' }
        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }

        # Assert that emails of user1 and user2 are in the result
        expect(ids).to include(user1.id, user2.id)

        # Assert that email of user3 is not in the result
        expect(ids).not_to include(user3.id)
      end

      it 'excludes a users outside a radius' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '15' }
        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }

        # Assert that ids of user1 and user2 are in the result
        expect(ids).to include(user1.id)

        # Assert that ids of user3 is not in the result
        expect(ids).not_to include(user3.id, user2.id)
      end

      it 'filters users by name query disregarding radius' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '100', query: user1.name }
        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).to include(user1.id)
        expect(ids).not_to include(user2.id, user3.id)
      end
    end

    context 'when bookings for a user are present of type only_once' do
      let!(:user1) { create(:user, :provider, location: 'POINT(0.0 0.0)', email: 'user1@someone.com', name: 'user1') }
      let!(:user2) { create(:user, :provider, location: 'POINT(0.1 0.1)', email: 'user2@someone.com', name: 'user2') }
      let!(:user3) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'user3@someone.com', name: 'user3') }
      let!(:client) { create(:user, :client, location: 'POINT(2.0 2.0)', email: 'user4@someone.com', name: 'user4') }

      let!(:booking) { create(:booking, :once, user: client, provider_id: user1.id, start_at: "2023-08-31T08:00:00UTC") }
      let!(:booking_slot1) { create(:booking_slot, booking: booking, user: user1, start_at: "2023-08-31T08:00:00UTC", end_at: "2023-08-31T10:00:00UTC" ) }

      it 'excludes the user with conflicting booking slots: same time' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T08:00:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

      it 'excludes the user with conflicting booking slots: one hour overlap out of two' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T07:00:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

      it 'includes all users since there is no overlap' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T05:59:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).to include(user1.id, user2.id, user3.id)
      end
    end

    context 'when bookings for a user are present of type once_a_week' do
      let!(:user1) { create(:user, :provider, location: 'POINT(0.0 0.0)', email: 'user1@someone.com', name: 'user1') }
      let!(:user2) { create(:user, :provider, location: 'POINT(0.1 0.1)', email: 'user2@someone.com', name: 'user2') }
      let!(:user3) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'user3@someone.com', name: 'user3') }
      let!(:client) { create(:user, :client, location: 'POINT(2.0 2.0)', email: 'user4@someone.com', name: 'user4') }

      let!(:booking) { create(:booking, :once_a_week, user: client, provider_id: user1.id, start_at: "2023-08-31T08:00:00UTC") }
      let!(:booking_slot1) { create(:booking_slot, booking: booking, user: user1, start_at: "2023-09-22 07:06:00.000", end_at: "2023-09-22 09:06:00.000" ) }
      let!(:booking_slot2) { create(:booking_slot, booking: booking, user: user1, start_at: "2023-10-07 07:06:00.000", end_at: "2023-10-07 09:06:00.000" ) }


      it 'excludes the user with conflicting booking slots: same time' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '500', hours: 2, start_at: "2023-09-22T07:00:00+00:00" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

      it 'excludes the user with conflicting booking slots: one hour overlap out of two' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T07:00:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

      it 'includes all users since there is no overlap' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T05:59:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).to include(user1.id, user2.id, user3.id)
      end

      it 'includes a user who has a conflict next week' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-09-07T07:00:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

    end

    context 'when bookings for a user are present of type twice_a_week' do
      let!(:user1) { create(:user, :provider, location: 'POINT(0.0 0.0)', email: 'user1@someone.com', name: 'user1') }
      let!(:user2) { create(:user, :provider, location: 'POINT(0.1 0.1)', email: 'user2@someone.com', name: 'user2') }
      let!(:user3) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'user3@someone.com', name: 'user3') }
      let!(:client) { create(:user, :client, location: 'POINT(2.0 2.0)', email: 'user4@someone.com', name: 'user4') }

      let!(:booking) { create(:booking, :twice_a_week, user: client, provider_id: user1.id, start_at: "2023-08-31T08:00:00UTC", offset:2) }
      let!(:booking_slot1) { create(:booking_slot, booking: booking, user: user1, start_at: "2023-08-31T08:00:00UTC", end_at: "2023-08-31T10:00:00UTC" ) }
      let!(:booking_slot2) { create(:booking_slot, booking: booking, user: user1, start_at: "2023-09-02T08:00:00UTC", end_at: "2023-09-02T10:00:00UTC" ) }


      it 'excludes the user with conflicting booking slots: same time' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T08:00:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

      it 'excludes the user with conflicting booking slots: one hour overlap out of two' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T07:00:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

      it 'includes all users since there is no overlap' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T05:59:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).to include(user1.id, user2.id, user3.id)
      end

      it 'includes a user who has a conflict the same week' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-09-02T07:00:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

    end

    context 'when bookings for a user are present of type once_every_two_weeks' do
      let!(:user1) { create(:user, :provider, location: 'POINT(0.0 0.0)', email: 'user1@someone.com', name: 'user1') }
      let!(:user2) { create(:user, :provider, location: 'POINT(0.1 0.1)', email: 'user2@someone.com', name: 'user2') }
      let!(:user3) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'user3@someone.com', name: 'user3') }
      let!(:client) { create(:user, :client, location: 'POINT(2.0 2.0)', email: 'user4@someone.com', name: 'user4') }

      let!(:booking) { create(:booking, :once_every_two_weeks, user: client, provider_id: user1.id, start_at: "2023-08-31T08:00:00UTC", offset:2) }
      let!(:booking_slot1) { create(:booking_slot, booking: booking, user: user1, start_at: "2023-08-31T08:00:00UTC", end_at: "2023-08-31T10:00:00UTC" ) }
      let!(:booking_slot2) { create(:booking_slot, booking: booking, user: user1, start_at: "2023-09-14T08:00:00UTC", end_at: "2023-09-14T10:00:00UTC" ) }


      it 'excludes the user with conflicting booking slots: same time' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T08:00:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

      it 'excludes the user with conflicting booking slots: one hour overlap out of two' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T07:00:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

      it 'includes all users since there is no overlap' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-08-31T05:59:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).to include(user1.id, user2.id, user3.id)
      end

      it 'includes a user who has a conflict the same week' do
        get :index, params: { latitude: '0.0', longitude: '0.0', radius: '350', hours: 2, start_at: "2023-09-14T07:00:00UTC" }

        expect(response).to have_http_status(:ok)

        parsed_response = JSON.parse(response.body)
        ids = parsed_response['users'].map { |user| user['id'] }
        expect(ids).not_to include(user1.id)
        expect(ids).to include(user2.id, user3.id)
      end

    end
  end
end
