class HoboMigration4 < ActiveRecord::Migration
  def self.up
    rename_column :fermentable_inventory_log_entries, :ammount, :amount
  end

  def self.down
    rename_column :fermentable_inventory_log_entries, :amount, :ammount
  end
end
