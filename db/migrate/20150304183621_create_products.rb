class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.string :first_category
      t.integer :stock
      t.string :currency
      t.boolean :digital

      t.timestamps null: false
    end
  end
end
