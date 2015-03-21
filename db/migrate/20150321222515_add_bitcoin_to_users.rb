class AddBitcoinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bitcoin, :boolean
  end
end
