class CreateInvoicesPayments < ActiveRecord::Migration
  def self.up
    create_table(:invoices_payments, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.references :invoice
      t.references :payment

      t.timestamps
    end

    execute "ALTER TABLE invoices_payments ADD FOREIGN KEY (invoice_id) REFERENCES invoices(id)"
    execute "ALTER TABLE invoices_payments ADD FOREIGN KEY (payment_id) REFERENCES payments(id)"
  end

  def self.down
    execute "ALTER TABLE invoices_payments DROP FOREIGN KEY invoices_payments_ibfk_1"
    execute "ALTER TABLE invoices_payments DROP FOREIGN KEY invoices_payments_ibfk_2"
    drop_table :invoices_payments
  end
end
