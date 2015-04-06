class AddDocumentToProducts < ActiveRecord::Migration
  def self.up
      add_attachment :products, :document
      add_attachment :products, :audio
    end

    def self.down
      remove_attachment :products, :document
      remove_attachment :products, :audio
    end
end
