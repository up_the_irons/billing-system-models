class SalesReceiptsLineItem < ActiveRecord::Base
  belongs_to :sales_receipt
end
