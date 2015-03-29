class AddProductIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :product_id, :integer
  end
end
