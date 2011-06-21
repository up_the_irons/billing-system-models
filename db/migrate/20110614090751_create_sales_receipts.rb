class CreateSalesReceipts < ActiveRecord::Migration
  def self.up
    create_table(:sales_receipts, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.references :account, :null => false
      t.date    :date
      t.text    :message

      t.timestamps
    end

    execute "ALTER TABLE sales_receipts ADD FOREIGN KEY (account_id) REFERENCES accounts(id)"
  end

  def self.down
    execute "ALTER TABLE sales_receipts DROP FOREIGN KEY sales_receipts_ibfk_1"
    drop_table :sales_receipts
  end
end
