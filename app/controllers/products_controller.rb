class ProductsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :list, :purchase, :store, :show, :info]
  # before_filter :identify_product, :except => [:index, :list, :purchase, :new, :create,:document_download, :edit, :show]
  
  
  def info
    @product = Product.find(params[:id])
  end
  
  def document_download
     @product = Product.find(params[:id])
     @file = "product_" + @product.id.to_s
     @path = @product.document.url
      if !@path.nil?
        data = open(@path) 
        
        case @product.second_category
        when "epub"
          send_data data.read, filename: "monfichier.epub", type: "application/epub+zip", disposition: 'attachment', stream: 'true', buffer_size: '4096'
        when "pdf"
          send_data data.read, filename: "monfichier.pdf", type: "application/pdf", disposition: 'attachment', stream: 'true', buffer_size: '4096'
        else
          redirect_to store_products_path
        end
        
      else 
         redirect_to store_products_path
      end
  end

  def video_download
     @product = Product.find(params[:id])
      file_path = @product.video_file_name
      if !file_path.nil?
  send_file "#{Rails.root}/public/system/photos/#{@product.id}/original/#{file_path}", :x_sendfile => true 
  else 
         redirect_to store_products_path
  end
  end

  def audio_download
     @product = Product.find(params[:id])
      file_path = @product.audio_file_name
      if !file_path.nil?
  send_file "#{Rails.root}/public/system/audios/#{@product.id}/original/#{file_path}", :x_sendfile => true 
  else 
         redirect_to store_products_path
  end
  end
  
  def list
    @products = Product.all
  end
  
  def index
    @products = Product.all
  end
  
  def store
    @products = Product.all.select { |m| m.stock != 0 and m.first_category != "membership" }
  end
  
  def new
    @product = Product.new
  end

  def show
    @product = Product.find_by_id(params[:id])
    # send_file @path, :disposition => "attachment; filename=#{@file}"
  end
  
  
  def purchase
      @products = Product.where(id: params[:id]).to_a
      render "visitors/index"
  end
  
  def pay
      # @products = Product.where(id: params[:id]).to_a
      @product = Product.find_by_id(params[:id])
      respond_to do |format|
          # that will mean to send a javascript code to client-side;
          format.js { render :action => "pay" }
          format.html { render :action => "pay" }
        end
  end
  
  def checkout
      # @products = Product.where(id: params[:id]).to_a
      @product = Product.find_by_id(params[:id])
      @user = current_user  # checkout method is called only when user is signed in
      @user.product_id = @product.id
      @user.save
      
      @orders = Order.all.select { |m| m.email == @user.email and m.status == "pending" }
      unless @orders.blank?
      @orders.each do |order|
        order.destroy
        end 
      end
      
      # product = @product
      @amount = @product.price.to_i/100.0 # price in EUR
      
      @order = Order.create(
        :email => current_user.email,
        :name => current_user.name,
        :street => current_user.street,
        :postal_code => current_user.postal_code,
        :city => current_user.city,
        :country => current_user.country,
        :amount => "#{@amount}",
        :content => "#{@product.title}",
        :currency    => 'EUR',
        :status    => 'pending',
        :pay_type => 'card',
        :signed_in => true,
        :user_id => current_user.id
        )
        
        if @order.save
          # using paymium_api gem:
          @client = Paymium::Api::Client.new  host: 'https://paymium.com/api/v1',
                                              key: Rails.application.secrets.paymium_api_key,
                                              secret: Rails.application.secrets.paymium_secret_key

          payment_request = @client.post '/merchant/create_payment',  amount:"#{@order.amount}" , 
                                                                      payment_split:"0", 
                                                                      currency:"EUR",
                                                                      callback_url: "#{$ORDERS_URL}callback"

          @order.address = payment_request["payment_address"]
          @btc_amount = payment_request["btc_amount"]
          @expiry = payment_request["expires_at"]

          @order.balance = @btc_amount.to_d
    		  @order.qrcode_string = "bitcoin:#{@order.address}?amount=#{@btc_amount}" # warning: make sure the number of decimals here matches that of the Paymium API
    		  @order.expiry = Time.at(@expiry.to_i).to_datetime
          @order.save

          end
      
  end
  
  
  def create
      @product = Product.new(product_params)

      if @product.save
        redirect_to @product, notice: 'Product was successfully created.'
       else
         render action: 'new'
      end
  end
    
  def edit
    @product = Product.find_by_id(params[:id])
  end
  
  def update
    @product = Product.find_by_id(params[:id])
    
    respond_to do |format|
      if @product.update_attributes(product_params)
        format.html { redirect_to(@product, :notice => 'Product was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end
    
  def destroy
    @product = Product.find_by_id(params[:id])
    @product.destroy
    @products = Product.all
    redirect_to list_products_path, notice: 'Product was successfully deleted.'
  end

  private
  
  def product_params
      params.require(:product).permit(:avatar,:document,:audio,:video, :title, :description,:price, :first_category,:second_category, :digital, :stock)
    end
  
  
  def identify_product
    valid_characters = "^[0-9a-zA-Z]*$".freeze
    unless params[:id].blank?
      @product_id = params[:id]
      @product_id = @product_id.tr("^#{valid_characters}", '')
    else
      raise "Filename missing"
    end
    unless params[:format].blank?
      @format = params[:format]
      @format = @format.tr("^#{valid_characters}", '')
    else
      raise "File extension missing"
    end
    @path = "app/views/products/#{@product_id}.#{@format}"
    @file = "#{@product_id}.#{@format}"
  end

end
