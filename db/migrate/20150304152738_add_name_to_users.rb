class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :street, :string
    add_column :users, :postal_code, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
  end
end
