class HoboMigration3 < ActiveRecord::Migration
  def self.up
    create_table :fermentable_inventory_log_entries do |t|
      t.float    :ammount
      t.text     :note
      t.datetime :usagetime
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :recipe_id
      t.integer  :fermentable_inventory_id
      t.integer  :user_id
    end
  end

  def self.down
    drop_table :fermentable_inventory_log_entries
  end
end
