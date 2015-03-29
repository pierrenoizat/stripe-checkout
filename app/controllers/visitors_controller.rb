class VisitorsController < ApplicationController
  
  def index
    @products = Product.all.select { |m| m.stock != 0 }
  end
  
end
