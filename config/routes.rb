Rails.application.routes.draw do
  namespace :admin do
    get 'units/index'
    get 'units/edit'
  end
  
  devise_for :users, controllers: {
    registrations: "public/registrations",
    sessions: 'public/sessions'
  }
  
  devise_scope :user do
    post 'user/guest_sign_in', to: 'public/sessions#guest_sign_in'
  end

  scope module: :public do
    root to: 'homes#top'
    resources :users, except: [:new, :index, :create] do
      get "unsubscribe"=>"users#unsubscribe"
      patch "withdrawal"=>"users#withdrawal"
    end
    
    resources :recipes do
      get "recalculation" => "recipes#recalculation"
      resource :favorites, only: [:create, :destroy]
    end
    
    resource :recipe, only: [:search] do
      get "search" => "recipes#search"
      delete "category_id_delete" => "recipes#category_id_delete"
      delete "category_id_all_delete" => "recipes#category_id_all_delete"
      get "search_category" => "recipes#search_category"
    end
    
    resources :reviews, only: [:create, :destroy]
    resource :reports, only: [:new, :create]
  end
  
  devise_for :admin ,controllers: {
    sessions: "admin/sessions"
  }
  
  namespace :admin do
    root to: 'homes#top'
    resources :users, except: [:new, :create]
    resources :genres, except: [:new, :show]
    resources :categories, except: [:new, :index, :show]
    resources :units, except: [:new, :show]
    resources :reports, only: [:show, :destroy]
  end

end
