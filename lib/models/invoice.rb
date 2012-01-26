class Invoice < ActiveRecord::Base
  belongs_to :account
  has_many :line_items, :class_name => 'InvoicesLineItem', :dependent => :destroy
  has_many :invoices_payments, :dependent => :destroy
  has_many :payments, :through => :invoices_payments

  named_scope :paid,   :conditions => 'paid = true'
  named_scope :unpaid, :conditions => 'paid = false'

  before_create :assign_bill_to

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

  def assign_bill_to
    if bill_to.nil? && account.respond_to?(:bill_to)
      bill_to = account.bill_to

      if !bill_to.nil?
        self.bill_to = bill_to
      end
    end
  end
end
