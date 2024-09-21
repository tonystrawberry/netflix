Rails.application.routes.draw do
  # Redirect the root path to the `/en` locale
  root to: redirect("/en")

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  devise_for :users,
    path: "",
    path_names: { sign_in: "login", sign_out: "logout", sign_up: "signup" },
    controllers: {
      registrations: "users/registrations",
      sessions: "users/sessions"
    }

  devise_for :administrators,
    path: "administrators",
    path_names: { sign_in: "login", sign_out: "logout" },
    controllers: {
      sessions: "administrators/sessions"
    }

  scope module: :secure do
    controller :movies do
      get "/movies" => :index
    end

    controller :profiles do
      get "profiles" => :index
      get "profiles/new" => :new
      get "profiles/:code" => :show, as: :profile
      post "profiles" => :create
      post "profiles/:code/select" => :select, as: :profiles_select
    end
  end

  namespace :editor do
    controller :movies do
      get "/movies" => :index
    end
  end

  scope "/:locale" do
    get "/" => "welcome#index", as: :welcome
  end
end
