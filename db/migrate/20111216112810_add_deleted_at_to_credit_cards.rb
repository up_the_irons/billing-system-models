class AddDeletedAtToCreditCards < ActiveRecord::Migration
  def self.up
    add_column :credit_cards, :deleted_at, :timestamp, :default => nil
  end

  def self.down
    remove_column :services, :deleted_at
  end
end
