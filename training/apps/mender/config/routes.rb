Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :patients, only: %i[create show] do
      get :lookup, on: :collection
    end
    resources :practitioners, only: %i[index show]
    resources :treatments, only: :index
    resources :slots, only: :index
    resources :appointments, only: %i[index create show update destroy]
    resources :invoices, only: %i[index show], param: :number
  end

  namespace :staff do
    resource :session, only: %i[new create destroy]
    resource :schedule, only: :show, controller: "schedule"
    resources :appointments, only: %i[show new create update] do
      resource :clinical_note, only: %i[create update] do
        post :sign
      end
    end
    resources :patients, only: %i[index show edit update]
    resources :practitioners, only: %i[index show edit update]
    resources :invoices, only: %i[index show create] do
      member do
        post :issue
        post :pay
        post :void
      end
    end
    resources :claims, only: :index do
      get :export, on: :collection
    end
    resources :waitlist_entries, only: %i[index create destroy]
    resource :report, only: :show
    root "schedule#show"
  end

  resources :bookings, only: %i[show destroy]

  root to: redirect("/staff")
end
