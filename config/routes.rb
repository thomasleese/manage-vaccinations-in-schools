Rails.application.routes.draw do
  root to: redirect("/start")

  mount Avo::Engine, at: Avo.configuration.root_path

  get "/start", to: "pages#start"
  get "/dashboard", to: "dashboard#index"

  get "/ping" => proc { [200, {}, ["PONG"]] }

  get "/reset", to: "dev#reset" if Rails.env.development? || Rails.env.test?

  get "/csrf", to: "csrf#new"

  resources :sessions, only: %i[index show] do
    resources :triage, only: %i[index show]

    resources :patients,
              only: %i[index show],
              path: "/vaccinations",
              as: :vaccinations,
              controller: :vaccinations do
      put "record", on: :member
      get "history", on: :member
      get "show-template", on: :collection
      get "record-template", on: :collection
    end

    get "setup-offline", to: "offline_passwords#new", on: :member
    post "setup-offline", to: "offline_passwords#create", on: :member
  end

  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end
end
