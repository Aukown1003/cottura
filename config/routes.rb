Rails.application.routes.draw do
  # 制限有りはdevise_for :users,skip: [:passwords], controllers: {
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
  end
  
  devise_for :admin ,controllers: {
    sessions: "admin/sessions"
  }
  namespace :admin do
    #以下adminはすべてこの中に
  end
  
end
