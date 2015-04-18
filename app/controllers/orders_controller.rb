class OrdersController < ApplicationController
  # protect_from_forgery :except => :callback
  skip_before_filter :verify_authenticity_token, :except => [:update, :create, :index]
  # before_filter :authenticate_user!, :except => [:index, :list, :purchase, :store, :show, :info]
  # before_filter :admin_only, :except => [:download,:show, :order_list]
  
    def index
      # @orders = Order.all
      @orders = Order.order("created_at ASC").all.select { |m| User.find_by_email(m.email) }
    end
    
    def create
        
        signed_in = user_signed_in?
        if signed_in
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
            :signed_in => signed_in,
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
    
    
    def complete
      @order = Order.find(params[:id])
      
      if user_signed_in?
        @user = current_user
      else
        @user = User.find_by_email(@order.email)
      end
      
      # render js: "window.location.pathname = #{complete_order_path(@order).to_json}"
      # render :js => "window.location = '/visitors/index'"
      # redirect_to order_list_user_path(@user)
      
      respond_to do |format|
              format.json
              format.html
            end

    end
    
    
    def callback # method called only if bitcoin payment is made
      
      @btc_address = params[:payment_address]
      @order = Order.find_by_address(@btc_address)
      
      @state = params[:state]
      if @state == "processing" or @state == "paid"
        @order.status = 'paid'
        @order.pay_type = 'bitcoin'
        @order.save
        flash.now[:success] = 'Bitcoin payment received! You signed up successfully.'
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
          format.html { redirect_to(@order, :notice => 'Card payment received, thank you: order was successfully completed.') }
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
  
    def admin_only
      unless current_user.admin?
        redirect_to :back, :alert => "Access denied."
      end
    end
  
end
