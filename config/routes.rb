Rails.application.routes.draw do
  root "static_pages#home"

  resources :static_pages, only: [] do
    collection do
      get :help
      get :about
      get :contact
    end
  end

  resource :session, only: [ :new, :create, :destroy ] do
    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"
  end

  resources :users do
    get "/signup", to: "new", on: :collection
  end

  resources :account_activations, only: [ :edit ]

  resources :password_resets, only: [ :new, :create, :edit, :update ]

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
