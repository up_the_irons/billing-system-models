class InvoicesLineItem < ActiveRecord::Base
  belongs_to :invoice

  before_validation :assign_date
  validates_presence_of :date

  def assign_date
    if date.nil?
      self.date = invoice.date
    end
  end
end
