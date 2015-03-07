class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def create_order(charge)
    @order = Order.new
    @order.amount = charge.amount
    # @customer = Stripe::Customer.find_by_id(charge.customer)
    # @order.email = @customer.email
    @order.save
    
  end
  
end
