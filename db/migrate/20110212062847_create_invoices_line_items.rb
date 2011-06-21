class CreateInvoicesLineItems < ActiveRecord::Migration
  def self.up
    create_table(:invoices_line_items, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.references :invoice, :null => false
      t.date    :date
      t.string  :code
      t.text    :description
      t.decimal :amount, :precision => 10, :scale => 2, :null => false, :default => '0.00'

      t.timestamps
    end

    execute "ALTER TABLE invoices_line_items ADD FOREIGN KEY (invoice_id) REFERENCES invoices(id)"
  end

  def self.down
    execute "ALTER TABLE invoices_line_items DROP FOREIGN KEY invoices_line_items_ibfk_1"
    drop_table :invoices_line_items
  end
end
