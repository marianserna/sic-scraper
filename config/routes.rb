Rails.application.routes.draw do
  root 'resolutions#index'
  resources :resolutions, only: %i[index show]
end
