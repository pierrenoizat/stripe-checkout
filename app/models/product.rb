class Product < ActiveRecord::Base

  has_many :line_items
  has_many :orders, :through => :line_items
  before_destroy :ensure_not_referenced_by_any_line_item
  after_initialize :set_default_stock, :if => :new_record?
  
  def set_default_stock
    self.stock ||= 1
  end

  private
  # ensure that there are no line items referencing this product

  def ensure_not_referenced_by_any_line_item
    if line_items.empty?
      return true
    else
      errors.add(:base, 'Line Items Present')
      return false
    end
  end
  
end
