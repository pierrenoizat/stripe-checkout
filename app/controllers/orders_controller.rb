class OrdersController < ApplicationController
  # protect_from_forgery :except => :callback
  skip_before_filter :verify_authenticity_token, :except => [:update, :create]
    
    def callback
      
      # @client = Paymium::Api::Client.new  host: 'https://paymium.com/api/v1',
      #                                    key: Rails.application.secrets.paymium_api_key,
      #                                    secret: Rails.application.secrets.paymium_secret_key

      # payment = @client.get('/user')
      # locked_euro = payment["locked_eur"]
      
      # Paymium API Account operation properties:
      # currency	currency	"BTC"
      # name	name of operation	"account_operation"
      # created_at	date created	"2013-10-22T14:30:06.000Z"
      # created_at_int	timestamp	1382452206
      # amount	currency amount	49.38727114
      # address	bitcoin address if any	"1FPDBXNqSkZMsw1kSkkajcj8berxDQkUoc"
      # tx_hash	bitcoin transaction hash if any	"86e6e72aa559428524e035cd6b2997004..."
      @user = current_user
      
      @btc_address = params[:payment_address]
      @order = Order.find_by_address(@btc_address)
      
      @state = params[:state]
      if @state == "processing" or @state == "paid"
        @order.status = 'paid'
        @order.save
        if @user.email == @order.email
          render "visitors/index"
        else
          render :nothing => true, :status => 200, :content_type => 'text/html'
        end

      else
        render :nothing => true, :status => 200, :content_type => 'text/html'
      end
    end

  private
    def secure_params
      params.require(:order).permit(:name, :address, :email, :amount, :status, :balance)
    end
  
  
end
