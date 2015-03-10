class OrdersController < ApplicationController
  # protect_from_forgery :except => :payment_notification
  def create
      @order = Order.create(order_params)
      
      if @order.save
        # require 'bitcoin-addrgen' # uses bitcoin-addrgen gem relying on ffi gem to call gmp C library
        # @btc_address = BitcoinAddrgen.generate_public_address($MPK, @order.id)
        
        @client = Paymium::Api::Client.new  host: 'https://paymium.com/api/v1',
                                            key: Rails.application.secrets.paymium_api_key,
                                            secret: Rails.application.secrets.paymium_secret_key
        
        @amnt = 200                                   
        payment_request = @client.post('/merchant/create_payment')  amount:"#{@amnt}" , 
                                                                    payment_split:"0", 
                                                                    currency:"EUR"
            
        # locked_euro = @client.get('/user')["locked_eur"]
        @btc_address = @client.get('/merchant/create_payment')["payment_address"]
  		  @order.qrcode_string = "bitcoin:#{@btc_address}?amount=#{@amnt}"
  		  @order.btc_address = @btc_address
  		  @order.update_attributes(:btc_address => @btc_address, :qrcode_string => @qrcode_string)
      end
      
    end
    
    def payment_notification
      
      # string = "http://www.bitcoinmonitor.net/api/v1/microbitcoin/863/notification/url/"
      # @agent = Mechanize.new
      # page = @agent.get string

      # data = page.body
      string = 'http://requestb.in/1b2c5wr1'
      require 'open-uri'
      result = open(string)

       # we convert the returned JSON data to native Ruby
       # data structure - a hash
       # result = JSON.parse(data)

    	amount = params['signed_data']['amount']  # amount is in satoshis
    	address = params['signed_data']['address'] 
    	# @order = Order.find_by_btc_address(address)
    	@order = Order.find_by_id(11) # test order
    	@order.update_attributes(:status => 'paid')
      
    end

  private
    def order_params
      params.require(:order).permit(:name, :btc_address, :email)
    end
  
  
end
