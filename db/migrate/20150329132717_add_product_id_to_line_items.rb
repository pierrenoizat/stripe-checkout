class AddProductIdToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :product_id, :integer
    add_column :line_items, :cart_id, :integer
    add_column :line_items, :order_id, :integer
  end
end
