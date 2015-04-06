class AddAvatarToProducts < ActiveRecord::Migration
  def self.up
      add_attachment :products, :avatar
    end

    def self.down
      remove_attachment :products, :avatar
    end
end
