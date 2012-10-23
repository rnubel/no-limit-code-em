NoLimitV2::Application.routes.draw do
  get "/" => 'home#index', :as => :root
  
  resources :tournaments do
  end

  resources :players do
  end

  namespace :api do
    resources :players do
      member do
        post 'action'
      end
    end
  end
end
