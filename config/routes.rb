Rails.application.routes.draw do
  get 'users/my_page'
  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index"
  
  resources :words, only: [:index, :show] do
    collection do
      get 'initial/:letter', to: 'words#initial', as: 'initial'
      get 'search', to: 'words#search', as: 'search'
    end
    member do
      post 'save', to: 'words#save'
    end
  end

  resources :lists do
    member do
      delete 'remove_word'
    end
  end

  get 'my_page', to: 'users#my_page'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
