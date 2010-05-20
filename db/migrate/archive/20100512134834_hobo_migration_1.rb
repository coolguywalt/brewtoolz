class HoboMigration1 < ActiveRecord::Migration
  def self.up
    add_column :recipes, :draft, :boolean
  end

  def self.down
    remove_column :recipes, :draft
  end
end
