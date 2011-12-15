class CreateCharges < ActiveRecord::Migration
  def self.up
    create_table(:charges, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.references :credit_card, :null => false
      t.date    :date
      t.decimal :amount, :precision => 10, :scale => 2, :null => false
      t.text    :gateway_response
      t.boolean :success, :null => false, :default => false

      t.timestamps
    end

    execute "ALTER TABLE charges ADD FOREIGN KEY (credit_card_id) REFERENCES credit_cards(id)"
  end

  def self.down
    execute "ALTER TABLE charges DROP FOREIGN KEY charges_ibfk_1"
    drop_table :charges
  end
end
