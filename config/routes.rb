Rails.application.routes.draw do
  resources :reservations, only: [:index, :create] do
    collection do
      get "available_dates"
      get "available_time"
      get "confirmation"
    end
  end
end
