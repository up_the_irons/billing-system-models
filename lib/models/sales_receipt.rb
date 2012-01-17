class SalesReceipt < ActiveRecord::Base
  belongs_to :account
  has_many :line_items, :class_name => 'SalesReceiptsLineItem', :dependent => :destroy

  class LineItemSumError < StandardError; end
end
