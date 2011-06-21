class CreateCreditCards < ActiveRecord::Migration
  def self.up
    create_table(:credit_cards, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.references :account, :null => false
      t.string     :number,         :limit => 32
      t.string     :month,          :limit => 2
      t.string     :year,           :limit => 4
      t.string     :cvv,            :limit => 7
      t.string     :first_name,     :limit => 32
      t.string     :last_name,      :limit => 32
      t.string     :display_number, :limit => 32

      t.string     :billing_name
      t.string     :billing_company
      t.string     :billing_address_1
      t.string     :billing_address_2
      t.string     :billing_city
      t.string     :billing_state
      t.string     :billing_postal_code
      t.string     :billing_country_iso_3166, :limit => 2
      t.string     :billing_phone

      t.timestamps
    end

    execute "ALTER TABLE credit_cards ADD FOREIGN KEY (account_id) REFERENCES accounts(id)"
  end

  def self.down
    execute "ALTER TABLE credit_cards DROP FOREIGN KEY credit_cards_ibfk_1"
    drop_table :credit_cards
  end
end
