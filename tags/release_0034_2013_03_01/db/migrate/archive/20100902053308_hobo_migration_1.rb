class HoboMigration1 < ActiveRecord::Migration
  def self.up
    create_table :fermentable_inventories do |t|
      t.float    :amount
      t.text     :comment
      t.string   :location
      t.string   :label
      t.datetime :source_date
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :fermentable_type_id
      t.integer  :user_id
    end
    
    create_table :yeast_inventories do |t|
      t.float    :amount
      t.text     :comment
      t.string   :location
      t.string   :label
      t.datetime :source_date
      t.string   :storage_type
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :yeast_type_id
      t.integer  :user_id
    end
    
    create_table :kit_inventories do |t|
      t.float    :amount
      t.text     :comment
      t.string   :location
      t.string   :label
      t.datetime :source_date
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :kit_type_id
      t.integer  :user_id
    end
    
    create_table :hops_inventories do |t|
      t.float    :amount
      t.text     :comment
      t.string   :location
      t.string   :label
      t.datetime :source_date
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :hop_type_id
      t.integer  :user_id
    end
  end

  def self.down
    drop_table :fermentable_inventories
    drop_table :yeast_inventories
    drop_table :kit_inventories
    drop_table :hops_inventories
  end
end
