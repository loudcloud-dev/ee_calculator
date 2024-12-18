Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :employees

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "reimbursements#index"
  resources :reimbursements, only: [ :index, :new, :create ]
  resources :leaves, only: [ :index, :new, :create ] do
    member do
      put :approve
      put :reject
    end
  end

  get "*path" => redirect("/"), constraints: lambda { |req| !req.path.starts_with?("/rails/active_storage") }
end
