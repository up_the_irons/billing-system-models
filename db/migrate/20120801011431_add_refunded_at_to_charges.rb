class AddRefundedAtToCharges < ActiveRecord::Migration
  def self.up
    add_column :charges, :refunded_at, :timestamp
  end

  def self.down
    remove_column :refunded_at
  end
end
