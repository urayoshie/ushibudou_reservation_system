Rails.application.routes.draw do
  root "homes#index"
  devise_for :admin_users, path: "admin"
  namespace :admin do
    root "homes#index"
    resources :notifications
  end
  resources :notifications, only: :index
  resources :reservations, only: [:index, :create] do
    collection do
      get "available_dates"
      get "available_time"
      get "confirmation"
    end
  end
end
