class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  
  def pay
    @user = User.new
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    
    price = Rails.application.secrets.product_price
    title = Rails.application.secrets.product_title
    
     @order = Order.create(
      :email => @user.email,
      :balance      => "#{price}",
      :total => "#{price}",
      :content => "#{title}",
      :currency    => 'usd',
      :pay_type => 'bitcoin'
      )
      
    if @order.save
      require 'bitcoin-addrgen' # uses bitcoin-addrgen gem relying on ffi gem to call gmp C library
      @btc_address = BitcoinAddrgen.generate_public_address($MPK, @order.id)
      # @order.qrcode_string = "bitcoin:#{@btc_address}?amount=#{@order.total}"
      # @order.btc_address = @btc_address
      # @order.qrcode_string = "bitcoin:#{@btc_address}?amount=#{@order.total}"
      @order.update_attributes(:btc_address => @btc_address, :qrcode_string => "bitcoin:#{@btc_address}?amount=#{@order.total}")
      end
    
    render :new
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
