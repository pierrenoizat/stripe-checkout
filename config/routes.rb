Rails.application.routes.draw do
  # get 'products/:id', to: 'products#show', :as => :products

  devise_for :users, :controllers => { :registrations => 'registrations' }
  devise_scope :user do
    post 'pay', to: 'registrations#pay'
    get 'pay', to: 'registrations#pay'
  end
  
  resources :orders do
	collection do
		post :callback
		get :callback
		put :callback
	end
	end
	
	resources :charges
  resources :orders
  
  resources :products do
      member do
        get 'purchase'
        post 'document_download'
        end
      collection do
        get 'list'
        get 'store'
        end
      end
      
      
  resources :users do
      member do
        get 'download'
        end
      end
  
  # resources :users
  root :to => 'visitors#index'
end
