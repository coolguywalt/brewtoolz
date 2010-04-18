class HoboMigration1 < ActiveRecord::Migration
  def self.up
    add_column :recipes, :locked, :boolean
  end

  def self.down
    remove_column :recipes, :locked
  end
end
