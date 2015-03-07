class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :name
      t.string :street
      t.string :postal_code
      t.string :city
      t.string :country
      t.string :email
      t.string :pay_type
      t.decimal :total
      t.string :content
      t.string :btc_address
      t.decimal :rate
      t.string :currency

      t.timestamps null: false
    end
  end
end
