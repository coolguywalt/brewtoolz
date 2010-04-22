class HoboMigration1 < ActiveRecord::Migration
  def self.up
    create_table :recipe_user_shareds do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :shared_state
      t.boolean  :can_edit
      t.boolean  :can_invite
      t.boolean  :can_update_message_log
      t.boolean  :can_email_group
      t.string   :notification_type
      t.datetime :last_notified
      t.integer  :recipe_shared_id
      t.integer  :user_id
    end
    
    create_table :recipe_shareds do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :last_updated
      t.integer  :recipe_id
      t.integer  :user_id
    end
  end

  def self.down
    drop_table :recipe_user_shareds
    drop_table :recipe_shareds
  end
end
