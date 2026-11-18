Rails.application.routes.draw do
  root "home#show"

  resources :articles, only: :show
  resources :sections, only: :show
  resources :authors, only: :show
  resources :tags, only: :show
  get "search", to: "search#index"
  resources :letters, only: %i[new create]
  get "letters/thanks", to: "letters#thanks", as: :letters_thanks

  namespace :api do
    resources :sections, only: :index
    resources :articles, only: %i[index show] do
      resources :comments, only: %i[index create]
    end
    resource :reader, only: %i[create show update destroy]
  end

  namespace :newsroom do
    root "dashboard#show"
    resource :session, only: %i[new create destroy]
    resources :articles, except: :destroy do
      member { patch :transition }
      resources :corrections, only: :create
    end
    resources :comments, only: %i[index update destroy]
    resources :letters, only: %i[index show update]
    resources :readers, only: %i[index show destroy]
    resources :sections, only: %i[index edit update]
    resource :settings, only: %i[edit update]
    resources :wire_imports, only: %i[index create]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
