class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  skip_before_filter :verify_authenticity_token, :except => [:pay]
  
  def pay
    @user = User.new
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    
    @users = User.order("created_at ASC").all.select { |m| m.email == @user.email }
    
    if !@users.blank?
      redirect_to new_user_session_path
    else
    #if verify_recaptcha :private_key => Rails.application.secrets.recaptcha_private_key, :model => @user, :message => "Oh! It's error with reCAPTCHA!"
      create_order(@user.email)
      # render :new  # form with payment options
      
      respond_to do |format|
          # that will mean to send a javascript code to client-side;
          format.js { render :action => "new" }
          format.html { render :action => "new" }
        end
    end
    #else
    #  render "visitors/index" 
    #end
  end
  
  
  # def new
  #  @user = User.new
  #  respond_to do |format|
  #      format .js  { @user = current_user }
  #      format .html
  #  end
    
  #end 


  def create
    if params[:bitcoin]
      @user = User.new
      @user.email = params[:email]
      @user.password = params[:password]
      @user.password_confirmation = params[:password]
      @user.bitcoin = params[:bitcoin]
      @user.save!
      sign_in(:user, @user)
      flash.now[:success] = 'Payment received! You signed up successfully.'
      redirect_to after_sign_in_path_for(@user)
    else
      params[:user][:email] = params[:stripeEmail]
      params[:user][:stripeToken] = params[:stripeToken]
      super
    end
      

  end
 
 
  protected
  def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up).push(:email, :stripeToken, :password)
  end
  
  def sign_up_params
      devise_parameter_sanitizer.sanitize(:sign_up)
    end
 
end
