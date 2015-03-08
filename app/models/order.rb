class Order < ActiveRecord::Base
  enum status: [:pending, :paid, :excess, :under]
  belongs_to :user
end
