class AddSignedInToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :signed_in, :boolean
  end
end
