class HoboMigration3 < ActiveRecord::Migration
  def self.up
    add_column :kit_types, :kit_type, :string
  end

  def self.down
    remove_column :kit_types, :kit_type
  end
end
