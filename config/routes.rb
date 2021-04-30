Rails.application.routes.draw do
  resources :reservations, only: :index do
    collection do
      get "available_dates"
      get "available_time"
    end
  end
end
