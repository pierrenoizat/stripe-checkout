class AddExpiryToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :expiry, :datetime
  end
end
