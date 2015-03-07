class OrdersController < ApplicationController
  
  def create
      @order = Order.create(order_params)
      
      if @order.save
        require 'bitcoin-addrgen' # uses bitcoin-addrgen gem relying on ffi gem to call gmp C library
        @btc_address = BitcoinAddrgen.generate_public_address($MPK, @order.id)
  		  @order.qrcode_string = "bitcoin:#{@btc_address}?amount=#{@amnt}"
  		  @order.btc_address = @btc_address
  		  @order.update_attributes(:btc_address => @btc_address)
      end
      
    end

  private
    def order_params
      params.require(:order).permit(:name, :btc_address, :email)
    end
  
  
end
