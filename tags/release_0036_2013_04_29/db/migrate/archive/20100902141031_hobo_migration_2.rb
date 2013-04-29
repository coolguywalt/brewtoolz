class HoboMigration2 < ActiveRecord::Migration
  def self.up
    add_column :hops_inventories, :aa, :float
    add_column :hops_inventories, :hop_form, :string
  end

  def self.down
    remove_column :hops_inventories, :aa
    remove_column :hops_inventories, :hop_form
  end
end
