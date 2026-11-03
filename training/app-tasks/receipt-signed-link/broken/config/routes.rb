Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :products, only: %i[index show]
  resources :receipts, only: :show
    resources :orders, only: %i[create show update]
  end
  namespace :admin do
    resources :orders, only: %i[index show]
  end
  resources :products, only: %i[index show]
  resources :receipts, only: :show

  root "products#index"
end
