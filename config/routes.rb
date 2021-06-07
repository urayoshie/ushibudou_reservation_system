Rails.application.routes.draw do
  root "reservations#index"
  resources :notifications, only: :index
  resources :menus, only: :index
  resources :menus, only: :index
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
    resources :sortable_menus, only: :update
    resources :reservations
    resources :day_conditions
    resources :temporary_dates do
      collection do
        get "holiday"
        post "holiday"
      end
    end
  end
end
