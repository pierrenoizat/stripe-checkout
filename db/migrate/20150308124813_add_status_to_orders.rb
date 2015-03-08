class AddStatusToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :status, :integer
    add_column :orders, :balance, :decimal
  end
end
