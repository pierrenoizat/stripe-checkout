class Order < ActiveRecord::Base
  after_initialize :set_default_pay_type, :if => :new_record?
  enum status: [:pending, :paid, :excess, :partial]
  belongs_to :user
  
  PAY_TYPES = ["bitcoin","card"]
  
  def set_default_pay_type
    self.pay_type ||= "card"
  end
  
end
