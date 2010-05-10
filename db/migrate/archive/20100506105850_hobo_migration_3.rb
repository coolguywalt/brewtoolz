class HoboMigration3 < ActiveRecord::Migration
  def self.up
    create_table :log_messages do |t|
      t.text     :message
      t.datetime :msgtime
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
    end
  end

  def self.down
    drop_table :log_messages
  end
end
