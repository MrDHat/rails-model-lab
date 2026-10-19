Rails.application.routes.draw do
  resources :tickets, only: [:index, :show, :update]
end
