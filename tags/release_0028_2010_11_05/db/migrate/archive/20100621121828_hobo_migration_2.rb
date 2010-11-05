class HoboMigration2 < ActiveRecord::Migration
  def self.up
    add_column :fermentable_types, :validated, :boolean
  end

  def self.down
    remove_column :fermentable_types, :validated
  end
end
