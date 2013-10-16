NoLimitV2::Application.routes.draw do
  get "/" => 'home#index', :as => :root
  get "/registration" => redirect('/pages/registration'), :as => :registration
  get "/scoreboard" => 'home#scoreboard', :as => :scoreboard
  
  resources :tournaments do
    collection do
      get 'scoreboard'
      get 'tables'
      get 'refresh'
    end
  end
  resources :rounds

  resources :players do
  end

  namespace :sandbox do
    resources :players do
      member do
        post 'action'
      end
    end
  end

  namespace :api do
    resources :players do
      member do
        post 'action'
      end
    end
  end
end
