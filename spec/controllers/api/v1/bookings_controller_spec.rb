require 'rails_helper'

RSpec.describe Api::V1::BookingsController, type: :controller do
  let!(:client) { create(:user, :client, location: 'POINT(2.0 2.0)', email: 'client@someone.com', name: 'client') }
  let!(:client2) { create(:user, :client, location: 'POINT(2.0 2.0)', email: 'client2@someone.com', name: 'client2') }

  let!(:provider) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'provider@someone.com', name: 'provider') }

  let!(:booking) { create(:booking, :once, :pending, user: client, provider_id: provider.id, start_at: "2023-08-31T08:00:00UTC") }
  let!(:booking2) { create(:booking, :once, :pending, user: client2, provider_id: provider2.id, start_at: DateTime.now + 1.days) }

  let!(:provider1) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'provider1@someone.com', name: 'provider1') }
  let!(:booking_once) { create(:booking, :once, :pending, user: client, provider_id: provider1.id, start_at: DateTime.now + 2.days, offset:0, hours: 2) }

  let!(:provider2) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'provider2@someone.com', name: 'provider2') }
  let!(:booking_once_a_week) { create(:booking, :once_a_week, :pending, user: client, provider_id: provider2.id, start_at: DateTime.now + 3.days, offset:0, hours: 2) }

  let!(:provider3) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'provider3@someone.com', name: 'provider3') }
  let!(:booking_twice_a_week) { create(:booking, :twice_a_week, :pending, user: client, provider_id: provider3.id, start_at: DateTime.now + 4.days, offset:2, hours: 2) }

  let!(:provider4) { create(:user, :provider, location: 'POINT(2.0 2.0)', email: 'provider4@someone.com', name: 'provider4') }
  let!(:booking_once_every_two_weeks) { create(:booking, :once_every_two_weeks, :pending, user: client, provider_id: provider4.id, start_at: DateTime.now + 5.days, offset:0, hours: 2) }


  # Assuming authentication token is used to authorize user
  before do
    allow(controller).to receive(:authenticate_from_token!).and_return(true)
    controller.instance_variable_set(:@api_user, client) # or provider based on the test
  end

  describe "GET index" do
    it "returns a list of bookings" do
      get :index
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(Booking.count).to eq(2)
      expect(parsed_response.count).to eq(1)
    end
  end

  describe "GET show booking that belongs to me" do
    it "returns the booking" do
      get :show, params: { id: booking.id }
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['id']).to eq(booking.id)
    end
  end

  describe "GET show booking that belongs to someone else" do
    it "does not return the booking" do
      get :show, params: { id: booking2.id }
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to eq(nil)
    end
  end

  describe "POST create a booking of type once" do
    it "creates a new booking and generates the proper slots" do
      post :create, params: {booking: {
        provider_id: provider.id,
        start_at: Time.now + 1.day,
        frequency: 'once',
        rate: 50,
        comments: 'Test comment',
        offset: 0,
        hours: 2
      }}
      expect(response).to have_http_status(:created)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['status']).to eq("pending")

      #no slots should be created because the booking is pending at this point
      expect(BookingSlot.count).to eq(0)
    end
  end

  describe "PATCH update" do
    it "updates a booking" do
      patch :update, params: {id: booking.id, booking:{ id: booking.id, comments: 'New comment' }}
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['comments']).to eq('New comment')
    end
  end

  describe "DELETE destroy" do
    it "cancels a booking" do
      delete :destroy, params: { id: booking.id }
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['status']).to eq("cancelled_by_client")
    end
  end

  describe "PUT accept" do
    it "accepts a booking of type once and creates one slot" do
      expect(booking_once.status).to eq("pending")
      put :accept, params: { id: booking_once.id }
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['status']).to eq("active")

      #slots should be created because the booking is active at this point
      expect(BookingSlot.count).to eq(1)
      expect(BookingSlot.first.start_at).to eq(booking_once.start_at)
      expect(BookingSlot.first.end_at).to eq(booking_once.start_at + booking_once.hours.hours)
      expect(BookingSlot.first.booking_id).to eq(booking_once.id)
      expect(BookingSlot.first.user_id).to eq(booking_once.user_id)
    end

    it "accepts a booking of type once_a_week and creates four or five slots" do
      expect(booking_once_a_week.status).to eq("pending")
      put :accept, params: { id: booking_once_a_week.id }
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['status']).to eq("active")

      #slots should be created because the booking is active at this point
      expect(BookingSlot.count).to eq(4).or eq(5)
      expect(BookingSlot.first.start_at).to eq(booking_once_a_week.start_at)
      expect(BookingSlot.first.end_at).to eq(booking_once_a_week.start_at + booking_once_a_week.hours.hours)
      expect(BookingSlot.first.booking_id).to eq(booking_once_a_week.id)
      expect(BookingSlot.first.user_id).to eq(booking_once_a_week.user_id)
    end

    it "accepts a booking of type twice_a_week and creates 8 or 9 slots" do
      expect(booking_twice_a_week.status).to eq("pending")
      put :accept, params: { id: booking_twice_a_week.id }
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['status']).to eq("active")

      #slots should be created because the booking is active at this point
      expect(BookingSlot.count).to eq(8).or eq(9)
      expect(BookingSlot.first.start_at).to eq(booking_twice_a_week.start_at)
      expect(BookingSlot.first.end_at).to eq(booking_twice_a_week.start_at + booking_twice_a_week.hours.hours)
      expect(BookingSlot.first.booking_id).to eq(booking_twice_a_week.id)
      expect(BookingSlot.first.user_id).to eq(booking_twice_a_week.user_id)
    end

    it "accepts a booking of type once_every_two_weeks and creates 2 or 3 slots" do
      expect(booking_once_every_two_weeks.status).to eq("pending")
      put :accept, params: { id: booking_once_every_two_weeks.id }
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['status']).to eq("active")

      #slots should be created because the booking is active at this point
      expect(BookingSlot.count).to eq(2).or eq(3)
      expect(BookingSlot.first.start_at).to eq(booking_once_every_two_weeks.start_at)
      expect(BookingSlot.first.end_at).to eq(booking_once_every_two_weeks.start_at + booking_once_every_two_weeks.hours.hours)
      expect(BookingSlot.first.booking_id).to eq(booking_once_every_two_weeks.id)
      expect(BookingSlot.first.user_id).to eq(booking_once_every_two_weeks.user_id)
    end
  end
end
