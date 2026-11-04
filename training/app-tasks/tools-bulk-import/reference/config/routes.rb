Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: %i[new create destroy]
  resources :tools, only: %i[index show new create edit update] do
    post :import, on: :collection
    resources :loans, only: :create
  end
  resources :loans, only: [] do
    patch :return, on: :member
  end
  resources :members, only: :show
  resources :categories, only: %i[index create destroy]

  root "tools#index"
end
