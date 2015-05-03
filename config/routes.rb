Rails.application.routes.draw do
  # get 'products/:id', to: 'products#show', :as => :products
  get 'static_pages/help'
  get 'static_pages/about'
  get 'static_pages/contact'
  
  devise_for :users, :controllers => { :registrations => 'registrations' }
  devise_scope :user do
    post 'pay', to: 'registrations#pay'
    get 'pay', to: 'registrations#pay'
  end
  
  resources :orders do
    member do
      get 'complete'
      end
	collection do
		post :callback
	end
	end
	
	resources :charges
  resources :orders
  
  resources :products do
      member do
        get 'purchase'
        get 'pay'
        post 'checkout'
        post 'document_download'
        post 'video_download'
        post 'audio_download'
        get 'info'
        end
      collection do
        get 'list'
        get 'store'
        end
      end
      
  resources :users do
        resources :orders
      end
      
  resources :users do
      member do
        get 'download'
        get 'order_list'
        end
      end
  
  # resources :users
  root :to => 'visitors#index'
end
