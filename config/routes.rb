# config/routes.rb

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users,
                 controllers: {
                   sessions: 'api/v1/users/sessions',
                   registrations: 'api/v1/users/registrations'
                 },
                 path: '',
                 path_names: {
                   sign_in: 'users/sign_in',
                   sign_out: 'users/sign_out',
                   registration: 'users'
                 }
      resources :users do
        resources :reviews, only: [:index, :create, :edit, :update, :destroy]
      end
      resources :orders
      get 'search/', to: 'search#index'
    end
  end
end
