class CreateSalesReceiptsLineItems < ActiveRecord::Migration
  def self.up
    create_table(:sales_receipts_line_items, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.references :sales_receipt, :null => false
      t.string  :code
      t.text    :description
      t.decimal :amount, :precision => 10, :scale => 2, :null => false, :default => '0.00'

      t.timestamps
    end

    execute "ALTER TABLE sales_receipts_line_items ADD FOREIGN KEY (sales_receipt_id) REFERENCES sales_receipts(id)"
  end

  def self.down
    execute "ALTER TABLE sales_receipts_line_items DROP FOREIGN KEY sales_receipts_line_items_ibfk_1"
    drop_table :sales_receipts_line_items
  end
end
