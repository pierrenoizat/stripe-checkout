class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  skip_before_filter :verify_authenticity_token, :except => [:pay]
  
  def pay
    
    if params[:user]
      product_id = params[:user][:product_id]  # to deal with case of sign up errors and customer click on pay button a second time
    end
    
    @product = Product.find_by_id(product_id)
    if @product
      
    @user = User.new
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    @user.product_id = params[:user][:product_id]
    
    @user.name = params[:user][:name]
    @user.street = params[:user][:street]
    @user.city = params[:user][:city ]
    @user.postal_code = params[:user][:postal_code]
    @user.country = params[:user][:country]
    
    @users = User.order("created_at ASC").all.select { |m| m.email == @user.email }
    
    if !@users.blank?
      redirect_to new_user_session_path, :flash => { :info => "Email is already taken: please sign in or sign up with another email." }
    else
    #if verify_recaptcha :private_key => Rails.application.secrets.recaptcha_private_key, :model => @user, :message => "Oh! It's error with reCAPTCHA!"
      # create_order(@user)
      # render :new  # form with payment options
      if create_order(@user)
      respond_to do |format|
          # that will mean to send a javascript code to client-side;
          format.js { render :action => "new" }
          format.html { render :action => "new" }
        end
      else
        redirect_to root_url, :flash => { :info => "An error prevented you from signing up. Please try again now." }
      end
    end
    else
      redirect_to root_url, :flash => { :info => "An error prevented you from signing up: no product selected." }
    end
  end
  


  def create
    if !params[:bitcoin].blank? # reminder: false is blank
      unless (params[:email] and User.find_by_email(params[:email]))  # in case create is called again after a successful sign up by card
        @user = User.new
        @user.email = params[:email]
        @user.password = params[:password]
        @user.password_confirmation = params[:password]
        @user.bitcoin = params[:bitcoin]
        @user.save!
        # @user.save
        @user = User.find_by_email(params[:email])
        
        @orders = Order.all.select { |m| m.email == @user.email }
        @order = @orders.last
        @order.user_id = @user.id
        @user.name = @order.name
        @user.street = @order.street
        @user.postal_code = @order.postal_code
        @user.city = @order.city
        @user.country = @order.country
        @user.save!
        @order.save
      
        redirect_to after_sign_up_path_for(@user), notice: "Bitcoin payment received, thank you! You signed up successfully."
      else
        @user = User.find_by_email(params[:email])
        unless user_signed_in?
          sign_in(@user)
        end
        redirect_to @user, notice: "Card payment received, thank you! You signed up successfully."
      end
      
    else
      params[:user][:email] = params[:stripeEmail]
      params[:user][:stripeToken] = params[:stripeToken]
      
      @user = User.new
      @user.email = params[:user][:email]
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      @user.bitcoin = false
      @user.stripeToken = params[:user][:stripeToken]
      @orders = Order.all.select { |m| m.email == @user.email }
      @order = @orders.last
      @products = Product.all.select { |m| m.title == @order.content }
      @product = @products.last
      @user.product_id = @product.id
      
      @user.name = @order.name
      @user.street = @order.street
      @user.postal_code = @order.postal_code
      @user.city = @order.city
      @user.country = @order.country
      # @order.user_id = @user.id
      # @order.save
      # sign_in(:user, @user)
      # redirect_to after_sign_up_path_for(@user)
      if @user.password
        if @user.password.length > 5 and @user.password == @user.password_confirmation
        flash.now[:notice] = "Card payment received, thank you! You signed up successfully."  # does NOT work !
        end
      end
      super
      
    end
  end
 
 
  protected
  
  def after_sign_up_path_for(resource)
      download_user_path(resource)
    end
  
  def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up).push(:email, :stripeToken, :password, :name, :street, :postal_code, :city, :country )
      devise_parameter_sanitizer.for(:account_update).push(:name, :street, :postal_code, :city, :country )
  end
  
  def sign_up_params
      devise_parameter_sanitizer.sanitize(:sign_up)
    end
    
    def update_params
        devise_parameter_sanitizer.sanitize(:account_update)
      end
 
end
