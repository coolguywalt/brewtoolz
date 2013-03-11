class HoboMigration5 < ActiveRecord::Migration
  def self.up
    create_table :kit_inventory_log_entries do |t|
      t.float    :amount
      t.text     :note
      t.datetime :usagetime
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :recipe_id
      t.integer  :kit_inventory_id
      t.integer  :user_id
    end
    
    create_table :hops_inventory_log_entries do |t|
      t.float    :amount
      t.text     :note
      t.datetime :usagetime
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :recipe_id
      t.integer  :hops_inventory_id
      t.integer  :user_id
    end
    
    create_table :yeast_inventory_log_entries do |t|
      t.float    :amount
      t.text     :note
      t.datetime :usagetime
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :recipe_id
      t.integer  :yeast_inventory_id
      t.integer  :user_id
    end
  end

  def self.down
    drop_table :kit_inventory_log_entries
    drop_table :hops_inventory_log_entries
    drop_table :yeast_inventory_log_entries
  end
end
