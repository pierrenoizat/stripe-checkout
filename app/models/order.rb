class Order < ActiveRecord::Base
  enum status: [:pending, :paid, :excess, :partial]
  belongs_to :user
end
