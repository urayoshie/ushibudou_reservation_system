Rails.application.routes.draw do
  root "reservations#index"
  resources :reservations, only: [:create] do
    collection do
      get "available_dates"
      get "available_time"
      get "confirmation"
    end
  end

  devise_for :admin_users, path: "admin"
  namespace :admin do
    root "homes#index"
    resources :notifications
    resources :menus
    resources :reservations
  end
end
