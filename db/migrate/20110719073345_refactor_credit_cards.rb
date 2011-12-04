class RefactorCreditCards < ActiveRecord::Migration
  def self.up
    remove_column :credit_cards, :number
    remove_column :credit_cards, :cvv

    add_column :credit_cards, :number, :text
  end

  def self.down
    fail "No going back"
  end
end
