class HoboMigration2 < ActiveRecord::Migration
  def self.up
    add_column :users, :default_locked_recipes, :boolean, :default => false
  end

  def self.down
    remove_column :users, :default_locked_recipes
  end
end
