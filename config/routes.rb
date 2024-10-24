Rails.application.routes.draw do
  get 'users/my_page'
  devise_for :users

  devise_scope :user do
    get 'users/edit_email', to: 'users/registrations#edit_email', as: 'edit_user_email'
    put 'users/update_email', to: 'users/registrations#update_email', as: 'update_user_email'
    get 'users/email_update_success', to: 'users/registrations#email_update_success', as: 'email_update_success'

    get 'users/edit_custom_password', to: 'users/registrations#edit_password', as: 'edit_custom_user_password'
    put 'users/update_custom_password', to: 'users/registrations#update_password', as: 'update_custom_user_password'
    get 'users/password_update_success', to: 'users/registrations#password_update_success', as: 'password_update_success'
  end


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
      patch 'change_name'
    end
  end

  get 'my_page', to: 'users#my_page'

  resources :quizzes, only: [:new, :create, :show] do
    member do
      post 'answer'
      get 'show_per_answer', to: 'quizzes#show_per_answer', as: 'show_per_answer'
      get 'results'
    end
    collection do
      get 'history'
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
