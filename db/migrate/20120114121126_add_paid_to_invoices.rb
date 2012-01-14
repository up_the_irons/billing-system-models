class AddPaidToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :paid, :boolean, :default => false
  end

  def self.down
    remove_column :invoices, :paid
  end
end
