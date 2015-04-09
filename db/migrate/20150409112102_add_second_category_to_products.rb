class AddSecondCategoryToProducts < ActiveRecord::Migration
  def change
    add_column :products, :second_category, :string
  end
end
