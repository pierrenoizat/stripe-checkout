class FixColumnName < ActiveRecord::Migration
  def change
      rename_column :orders, :btc_address, :address
    end

end
