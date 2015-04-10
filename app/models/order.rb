class Order < ActiveRecord::Base
  after_initialize :set_default_pay_type, :if => :new_record?
  enum status: [:pending, :paid, :excess, :partial]
  belongs_to :user
  
  PAY_TYPES = ["bitcoin","card"]
  
  validates :email, :status, :presence => true
  validates :pay_type, :inclusion => PAY_TYPES
  # validates :country, :inclusion => COUNTRIES
  # validates :btc_address, :inclusion => BTC_ADDRESSES, :if => :btc_order?
  # inclusion validation commented out when using an unlimited deterministic address set (wallet)
  validates_format_of :email, :with => /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i, :multiline => true
  
  def set_default_pay_type
    self.pay_type ||= "card"
  end
  
end
