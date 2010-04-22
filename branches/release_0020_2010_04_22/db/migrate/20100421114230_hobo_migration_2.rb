class HoboMigration2 < ActiveRecord::Migration
  def self.up
    remove_column :recipe_shareds, :user_id
  end

  def self.down
    add_column :recipe_shareds, :user_id, :integer
  end
end
