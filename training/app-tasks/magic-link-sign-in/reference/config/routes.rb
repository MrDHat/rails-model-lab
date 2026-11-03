Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: %i[new create destroy]
  get "session/link" => "sessions#link", as: :session_link
  post "session/link" => "sessions#send_link"
  resources :tools, only: %i[index show new create edit update] do
    resources :loans, only: :create
  end
  resources :loans, only: [] do
    patch :return, on: :member
  end
  resources :members, only: :show
  resources :categories, only: %i[index create destroy]

  root "tools#index"
end
