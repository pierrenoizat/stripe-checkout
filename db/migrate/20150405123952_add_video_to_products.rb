class AddVideoToProducts < ActiveRecord::Migration
  def self.up
      add_attachment :products, :video
    end

    def self.down
      remove_attachment :products, :video
    end
end
