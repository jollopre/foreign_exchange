Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :exchange_rates, only: [:index]
  get 'exchange_rates/at', to: 'exchange_rates#at'
end
