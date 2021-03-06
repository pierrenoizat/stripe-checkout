class UsersController < ApplicationController
  before_action :authenticate_user!, :except => [:download,:show]
  before_filter :admin_only, :except => [:download,:show, :order_list]
  
  def order_list  # TO DO delete expired bitcoin addresses
    
    @user = User.find(params[:id])
    # @orders = Order.where(email: @user.email)
    @orders = Order.order("created_at ASC").all.select { |m| m.email == @user.email and m.status == "paid" }
    
  end

  def download
    @user = User.find(params[:id])
    unless user_signed_in?
      sign_in(@user)
    end
    redirect_to root_url
  end


  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    unless current_user.admin?
      unless @user == current_user
        redirect_to :back, :alert => "Access denied."
      end
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to users_path, :notice => "User deleted."
  end

  private

  def admin_only
    unless current_user.admin?
      redirect_to :back, :alert => "Access denied."
    end
  end

  def secure_params
    params.require(:user).permit(:role,:email, :product_id, :bitcoin, :name, :street, :postal_code, :city, :country )
  end

end
