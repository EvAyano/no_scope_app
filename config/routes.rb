Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  devise_scope :user do
    get 'users/edit_email', to: 'users/registrations#edit_email', as: 'edit_user_email'
    put 'users/update_email', to: 'users/registrations#update_email', as: 'update_user_email'
    get 'users/email_update_success', to: 'users/registrations#email_update_success', as: 'email_update_success'

    get 'users/edit_custom_password', to: 'users/registrations#edit_password', as: 'edit_custom_user_password'
    put 'users/update_custom_password', to: 'users/registrations#update_password', as: 'update_custom_user_password'
    get 'users/password_update_success', to: 'users/registrations#password_update_success', as: 'password_update_success'
  
    get 'users/edit_nickname', to: 'users/registrations#edit_nickname', as: 'edit_user_nickname'
    put 'users/update_nickname', to: 'users/registrations#update_nickname', as: 'update_user_nickname'
    
    get 'users/edit_avatar', to: 'users/registrations#edit_avatar', as: 'edit_user_avatar'
    patch 'users/update_avatar', to: 'users/registrations#update_avatar', as: 'update_user_avatar'
  end
  


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index"
  
  resources :words, only: [:index, :show] do
    collection do
      get 'filter', to: 'words#filter', as: 'filter'
      get 'initial/:letter', to: 'words#initial', as: 'initial'
      get 'search', to: 'words#search', as: 'search'
    end
    member do
      post 'save', to: 'words#save'
    end
  end

  resources :quizzes, only: [] do
    collection do
      get 'play'
      post 'play'
      get 'history'
    end
  end
  

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
