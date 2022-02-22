Rails.application.routes.draw do
  devise_for :admins
  devise_for :users

  namespace :site do
    get 'welcome/index'
  end
  namespace :users_backoffice do
    get 'welcome/index'
  end
  namespace :admins_backoffice do
    get 'welcome/index' #dashboard
    resources :admins
    resources :subjects
    resources :questions
  end

  root to: 'site/welcome#index'
end
