class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :create_order
  
  def create_order(email)
    @order = Order.create(
      :email => email,
      :balance      => "#{Rails.application.secrets.product_price}",
      :total => "#{Rails.application.secrets.product_price}",
      :content => "#{Rails.application.secrets.product_title}",
      :currency    => 'eur',
      :status    => 'pending',
      :pay_type => 'bitcoin'
      )
      
    if @order.save
      # require 'bitcoin-addrgen' # uses bitcoin-addrgen gem relying on ffi gem to call gmp C library
      # @btc_address = BitcoinAddrgen.generate_public_address($MPK, @order.id)
      # @btc_address = '16QGg8ERSS3Je2ia4HEaLMrEN2oUxwCxYS'  # test address for bitcoinmonitor.net
      # @order.qrcode_string = "bitcoin:#{@btc_address}?amount=#{@order.total}"
      # @order.btc_address = @btc_address
      # @order.qrcode_string = "bitcoin:#{@btc_address}?amount=#{@order.total}"
      
      @client = Paymium::Api::Client.new  host: 'https://paymium.com/api/v1',
                                          key: Rails.application.secrets.paymium_api_key,
                                          secret: Rails.application.secrets.paymium_secret_key
      
      @amnt = 200                                   
      payment_request = @client.post '/merchant/create_payment',  amount:"#{@amnt}" , 
                                                                  payment_split:"0", 
                                                                  currency:"EUR"
          
      # locked_euro = @client.get('/user')["locked_eur"]
      @btc_address = payment_request["payment_address"]
		  @order.qrcode_string = "bitcoin:#{@btc_address}?amount=#{@amnt}"
		  @order.btc_address = @btc_address
		  # @order.update_attributes(params[:order])
      @order.save
      # @order.update_attributes(:btc_address => @btc_address, :qrcode_string => "bitcoin:#{@btc_address}?amount=#{@order.total}")
      end
    
  end
  
end
