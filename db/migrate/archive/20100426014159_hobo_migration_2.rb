class HoboMigration2 < ActiveRecord::Migration
  def self.up
    add_column :kit_types, :yeild, :float
    add_column :kit_types, :type, :string
  end

  def self.down
    remove_column :kit_types, :yeild
    remove_column :kit_types, :type
  end
end
