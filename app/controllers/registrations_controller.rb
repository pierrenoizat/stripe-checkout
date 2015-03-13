class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  
  def pay
    @user = User.new
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    
    #if verify_recaptcha :private_key => Rails.application.secrets.recaptcha_private_key, :model => @user, :message => "Oh! It's error with reCAPTCHA!"
      create_order(@user.email)
      render :new  # form with payment options
    #else
    #  render "visitors/index" 
    #end
  end

  def create
    params[:user][:email] = params[:stripeEmail]
    params[:user][:stripeToken] = params[:stripeToken]
    
    super
  end
 
  protected
  def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up).push(:email, :stripeToken)
  end
 
end
