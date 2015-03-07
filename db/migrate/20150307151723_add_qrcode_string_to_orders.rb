class AddQrcodeStringToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :qrcode_string, :string
  end
end
