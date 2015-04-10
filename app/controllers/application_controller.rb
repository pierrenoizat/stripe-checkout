class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :create_order
  
  helper_method :set_flag_id, :set_flag_string
  
  before_filter :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  def set_flag_id(value)
    
    @flag_id = "fr"
		@flag_id = case value
		 when :fr then "fr"
		 when :en then "us"
		 else "fr" 
		 end
		@flag_id
    
  end
  
  def set_flag_string(value)
    
    @flag_string = "Français"
		@flag_string = case value
		 when :fr then "Français"
		 when :en then "English"
		 else "Français" 
		 end
		@flag_string
    
  end
  
  
  def create_order(user)
    
    require 'bigdecimal'
    require 'bigdecimal/util'
    
    @product = Product.find_by_id(params[:user][:product_id])
    
    password = params[:user][:password]
    password_confirmation = params[:user][:password_confirmation]
    
    valid_password = (password.length.between?(6,128) and (password == password_confirmation)) # pwd length range must be identical to config/initializers/devise.rb setting
    
    if @product and valid_password
    @amount = @product.price.to_i/100.0 # price in EUR
    
    @order = Order.create(
      :email => user.email,
      :amount => "#{@amount}",
      :content => "#{@product.title}",
      :currency    => 'EUR',
      :status    => 'pending'
      )
      
    if @order.save
      # require 'bitcoin-addrgen' # uses bitcoin-addrgen gem relying on ffi gem to call gmp C library
      # @btc_address = BitcoinAddrgen.generate_public_address($MPK, @order.id)

      # using paymium_api gem:
      @client = Paymium::Api::Client.new  host: 'https://paymium.com/api/v1',
                                          key: Rails.application.secrets.paymium_api_key,
                                          secret: Rails.application.secrets.paymium_secret_key
                                       
      payment_request = @client.post '/merchant/create_payment',  amount:"#{@order.amount}" , 
                                                                  payment_split:"0", 
                                                                  currency:"EUR",
                                                                  callback_url: "#{$ORDERS_URL}callback"
          
      @order.address = payment_request["payment_address"]
      @btc_amount = payment_request["btc_amount"]
      @expiry = payment_request["expires_at"]

      @order.balance = @btc_amount.to_d
		  @order.qrcode_string = "bitcoin:#{@order.address}?amount=#{@btc_amount}" # warning: make sure the number of decimals here matches that of the Paymium API
		  @order.expiry = Time.at(@expiry.to_i).to_datetime
      @order.save

      end
    else
      @order = nil
    end
    
  end
  
  
  
  protected
  
  def set_locale
    if params[:l] && I18n.available_locales.include?(params[:l].to_sym)
      I18n.locale = params[:l]
      session[:locale] = params[:l]
    elsif session[:locale]
      I18n.locale = session[:locale].to_sym
    else
      session[:locale] = I18n.default_locale
    end
  end


  def default_url_options
    { :locale => I18n.locale }
    end
  
  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(User)
        user_path(resource)
      else
        super
      end
  end
  
  def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, :remember_me, :product_id, :bitcoin) }
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit( :email, :password, :remember_me) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password) }
    end
  
end
