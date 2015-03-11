Rails.application.routes.draw do
  get 'products/:id', to: 'products#show', :as => :products
  devise_for :users, :controllers => { :registrations => 'registrations' }
  devise_scope :user do
    post 'pay', to: 'registrations#pay'
  end
  
  resources :orders do
	collection do
		post :callback
		get :callback
		put :callback
	end
	end
  
  resources :users
  root :to => 'visitors#index'
end
