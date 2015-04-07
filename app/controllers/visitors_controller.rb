class VisitorsController < ApplicationController
  # before_filter :authenticate_user!
  def index
    @products = Product.all.select { |m| m.stock != 0 and m.first_category == "membership"}
    
    #if user_signed_in?
    #  @products = Product.all.select { |m| (m.stock != 0 and m.id == current_user.product_id) }
    #end
    
  end
  
end
