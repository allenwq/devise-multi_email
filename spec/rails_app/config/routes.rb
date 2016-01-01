Rails.application.routes.draw do
  # Resources for testing
  resources :users, only: [:index] do
    member do
      get :expire
      get :accept
      get :edit_form
      put :update_form
    end

    authenticate do
      post :exhibit, on: :member
    end
  end

  # Users scope
  devise_for :users

  as :user do
    get '/as/sign_in', to: 'devise/sessions#new'
  end

  get '/sign_in', to: 'devise/sessions#new'

  authenticated do
    get '/dashboard', to: 'home#user_dashboard'
  end

  unauthenticated do
    get '/join', to: 'home#join'
  end

  get '/set', to: 'home#set'
  get '/unauthenticated', to: 'home#unauthenticated'

  root to: 'home#index', via: [:get, :post]
end
