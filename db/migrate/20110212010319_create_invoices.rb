class CreateInvoices < ActiveRecord::Migration
  def self.up
    begin
      create_table(:accounts, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
        t.timestamps
      end
    rescue ActiveRecord::StatementInvalid => e
      if e.message =~ /Table .* already exists/
        puts "accounts table already exists, skipping..."
      else
        raise
      end
    end

    create_table(:invoices, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.references :account, :null => false
      t.date    :date
      t.string  :terms
      t.text    :message

      t.timestamps
    end

    execute "ALTER TABLE invoices ADD FOREIGN KEY (account_id) REFERENCES accounts(id)"
  end

  def self.down
    execute "ALTER TABLE invoices DROP FOREIGN KEY invoices_ibfk_1"
    drop_table :invoices
  end
end
