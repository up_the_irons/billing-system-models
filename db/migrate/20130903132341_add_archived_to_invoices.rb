class AddArchivedToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :archived, :boolean, :default => false
  end

  def self.down
    remove_column :invoices, :archived
  end
end
