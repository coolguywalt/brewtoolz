class HoboMigration4 < ActiveRecord::Migration
  def self.up
    add_column :hop_types, :validated, :boolean
    add_column :hop_types, :user_id, :integer
  end

  def self.down
    remove_column :hop_types, :validated
    remove_column :hop_types, :user_id
  end
end
