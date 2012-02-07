class Invoice < ActiveRecord::Base
  belongs_to :account
  has_many :line_items, :class_name => 'InvoicesLineItem', :dependent => :destroy
  has_many :invoices_payments, :dependent => :destroy
  has_many :payments, :through => :invoices_payments, :dependent => :destroy

  named_scope :paid,   :conditions => 'paid = true'
  named_scope :unpaid, :conditions => 'paid = false'

  before_create :assign_bill_to

  before_validation :assign_date
  validates_presence_of :date

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

  def paid?
    read_attribute(:paid)
  end

  def assign_date
    if new_record? && date.nil?
      self.date = Time.now
    end
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
