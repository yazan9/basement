# config/routes.rb

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users,
                 controllers: {
                   sessions: 'api/v1/users/sessions',
                   registrations: 'api/v1/users/registrations',
                   confirmations: 'api/v1/users/confirmations',
                 },
                 path: '',
                 path_names: {
                   sign_in: 'users/sign_in',
                   sign_out: 'users/sign_out',
                   registration: 'users',
                   confirmations: 'users/confirmations',
                 }
      resources :users do
        resources :reviews, only: [:index, :create, :edit, :update, :destroy]
        member do
          put :profile_image
        end
      end

      resources :bookings, only: [:index, :show, :create, :update, :destroy] do
        member do
          put :accept
        end
      end

      resources :conversations, only: [:index, :create, :destroy] do
        resources :messages, only: [:index, :create, :destroy, :update]
      end

      get 'search/', to: 'search#index'
    end
  end
end
