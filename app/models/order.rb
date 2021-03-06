class Order < ActiveRecord::Base
  has_many :order_items
  has_many :menu_items, through: :order_items
  belongs_to :user

  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: :true
  accepts_nested_attributes_for :user

  STATUS = %w(pending processed canceled)

  validates_presence_of :user

  validates :pickup_time, date: { after: Proc.new { Time.now }, message: '%{value} didn\'t pass validation'}
  validates :status, inclusion: Order::STATUS

  scope :canceled, lambda { where(status: 'canceled') }
  scope :pending, lambda { where(status: 'pending') }
  scope :processed, lambda { where(status: 'processed') }

  before_save :calculate_amount

  def set_status(state)
    self.update_attribute(:status, state)
  end

  def self.item_in_order?(item_to_check)
    # Checks whether the input menu_item is included in any order.
    return true if item_to_check.orders && item_to_check.orders.count > 0
    false
  end
  
  private

  def calculate_amount
    self.amount = order_items.reduce(0) { |total, item| total += item.menu_item.price * item.quantity }
  end

end
