class OrdersController < ApplicationController
  # protect_from_forgery :except => :callback
  skip_before_filter :verify_authenticity_token, :except => [:update, :create]
  
    def index
      # @orders = Order.all
      @orders = Order.order("created_at ASC").all.select { |m| User.find_by_email(m.email) }
    end
    
    def create
      
        if user_signed_in?
          @product = Product.find_by_id(current_user.product_id)
        end
        
        if params[:stripeEmail]
          @order = Order.new(
            :email => params[:stripeEmail],
            :name => current_user.name,
            :street => current_user.street,
            :postal_code => current_user.postal_code,
            :city => current_user.city,
            :country => current_user.country,
            :currency    => 'EUR',
            :content => @product.title,
            :status    => 'paid',
            :pay_type => 'card'
            )
        end
        
        if @order.save
          redirect_to @order, notice: 'Order was successfully created.'
         else
           render action: 'new'
        end
    end
  
    def show
      @order = Order.find(params[:id])
      
      if user_signed_in?
        @user = current_user
      else
        @user = User.find_by_email(@order.email)
      end
      
      respond_to do |format|
              format.json
              format.html
            end

    end
    
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
      
      @btc_address = params[:payment_address]
      @order = Order.find_by_address(@btc_address)
      
      @state = params[:state]
      if @state == "processing" or @state == "paid"
        @order.status = 'paid'
        @order.pay_type = 'bitcoin'
        @order.save
        flash.now[:success] = 'Payment received! You signed up successfully.'
      end
      render :nothing => true, :status => 200, :content_type => 'text/html'
    end
    
    
    def update
      @order = Order.find_by_id(params[:id])
      if params[:stripeEmail]
        @order.status = 'paid'
      end
      
      respond_to do |format|
        
        if @order.update(status: "paid")
          format.html { redirect_to(@order, :notice => 'Order was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    def destroy
      order = Order.find(params[:id])
      order.destroy
      redirect_to orders_path, :notice => "Order deleted."
    end

  private
    def secure_params
      params.require(:order).permit(:name, :address, :email, :content, :amount, :status, :balance, :pay_type, :user_id, :stripeToken, :stripeEmail, :stripeTokenType)
    end
  
  
end
