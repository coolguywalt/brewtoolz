class HoboMigration4 < ActiveRecord::Migration
  def self.up
    add_column :kit_types, :designed_volume, :float
  end

  def self.down
    remove_column :kit_types, :designed_volume
  end
end
