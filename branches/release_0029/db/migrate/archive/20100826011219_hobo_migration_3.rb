class HoboMigration3 < ActiveRecord::Migration
  def self.up
    add_column :kit_types, :validated, :boolean
    add_column :kit_types, :user_id, :integer
  end

  def self.down
    remove_column :kit_types, :validated
    remove_column :kit_types, :user_id
  end
end
