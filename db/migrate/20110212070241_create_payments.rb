class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table(:payments, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.references :account, :null => false
      t.text    :reference_number
      t.date    :date
      t.text    :description
      t.string  :method, :limit => 16
      t.integer :check_number
      t.decimal :amount, :precision => 10, :scale => 2, :null => false, :default => '0.00'
      t.text    :notes
      t.text    :raw

      t.timestamps
    end

    execute "ALTER TABLE payments ADD FOREIGN KEY (account_id) REFERENCES accounts(id)"
  end

  def self.down
    execute "ALTER TABLE payments DROP FOREIGN KEY payments_ibfk_1"
    drop_table :payments
  end
end
