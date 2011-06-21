class Invoice < ActiveRecord::Base
  belongs_to :account
  has_many :line_items, :class_name => 'InvoicesLineItem'
  has_many :invoices_payments
  has_many :payments, :through => :invoices_payments

  def total
    line_items.inject(0) do |sum, li| 
      sum + li.amount
    end
  end

  def paid
    payments.inject(0) do |sum, p| 
      sum + p.amount
    end
  end

  def balance
    total - paid
  end
end
