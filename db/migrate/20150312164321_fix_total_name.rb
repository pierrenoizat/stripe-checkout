class FixTotalName < ActiveRecord::Migration
  def change
    rename_column :orders, :total, :amount
  end
end
