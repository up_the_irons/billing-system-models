class Payment < ActiveRecord::Base
  belongs_to :account
  has_many :invoice_payments
  has_many :invoices, :through => :invoice_payments
end
