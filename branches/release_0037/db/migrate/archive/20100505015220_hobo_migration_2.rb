class HoboMigration2 < ActiveRecord::Migration
  def self.up
    change_column :users, :last_activity, :integer, :limit => 4
  end

  def self.down
    change_column :users, :last_activity, :datetime
  end
end
