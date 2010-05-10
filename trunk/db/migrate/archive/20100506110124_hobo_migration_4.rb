class HoboMigration4 < ActiveRecord::Migration
  def self.up
    add_column :log_messages, :msgtype, :text
  end

  def self.down
    remove_column :log_messages, :msgtype
  end
end
