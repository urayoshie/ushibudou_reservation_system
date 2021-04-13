Rails.application.routes.draw do
  get "/reservations/index", to: "reservations#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
