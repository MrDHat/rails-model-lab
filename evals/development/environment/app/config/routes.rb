Rails.application.routes.draw do
  resources :expense_claims, only: [:create, :update, :show]
end
