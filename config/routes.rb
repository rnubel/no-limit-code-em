NoLimitV2::Application.routes.draw do
  get "/" => 'home#index', :as => :root
  get "/registration" => redirect('/pages/registration'), :as => :registration
  
  resources :tournaments do
    collection do
      get 'scoreboard'
      get 'tables'
    end
  end

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
