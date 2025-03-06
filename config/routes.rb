Rails.application.routes.draw do
  get 'contacts/index'
  devise_for :users, controllers: { 
    registrations: 'users/registrations', 
    passwords: 'users/passwords' 
  }

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

    get 'users/password_reset_success', to: 'users/passwords#password_reset_success', as: 'password_reset_success'
  end
  
  root "home#index"
  
  resources :words, only: [:index, :show] do
    collection do
      get 'filter', to: 'words#filter', as: 'filter'
      get 'search', to: 'words#search', as: 'search'
    end
  end

  resources :favorites, only: [:index, :create, :destroy]

  resources :quizzes, only: [] do
    collection do
      get 'play'
      post 'play'
      get 'history'
    end
  end

  get 'contacts/new', to: 'contacts#new', as: 'new_contact'
  post 'contacts', to: 'contacts#create'
  get 'contacts/completed', to: 'contacts#completed', as: 'contacts_completed'

  get "up" => "rails/health#show", as: :rails_health_check
  
  get '*not_found',
    to: 'errors#not_found',
    constraints: ->(req) { !req.path.include?('rails/active_storage') }

  post '*not_found',
    to: 'errors#not_found',
    constraints: ->(req) { !req.path.include?('rails/active_storage') }
end
