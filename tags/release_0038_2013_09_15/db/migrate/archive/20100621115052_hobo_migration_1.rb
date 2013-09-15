class HoboMigration1 < ActiveRecord::Migration
  def self.up
    add_column :fermentable_types, :user_id, :integer
  end

  def self.down
    remove_column :fermentable_types, :user_id
  end
end
