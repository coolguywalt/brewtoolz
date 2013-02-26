class InventoryLogModify < ActiveRecord::Migration
  def self.up
	add_column :yeast_inventory_log_entries, :brew_entry_id, :integer
	remove_column :yeast_inventory_log_entries, :recipe_id

	add_column :fermentable_inventory_log_entries, :brew_entry_id, :integer
	remove_column :fermentable_inventory_log_entries, :recipe_id

	add_column :hops_inventory_log_entries, :brew_entry_id, :integer
	remove_column :hops_inventory_log_entries, :recipe_id

	add_column :kit_inventory_log_entries, :brew_entry_id, :integer
	remove_column :kit_inventory_log_entries, :recipe_id
  end

  def self.down
	remove_column :yeast_inventory_log_entries, :brew_entry_id, :integer
	add_column :yeast_inventory_log_entries, :recipe_id

	remove_column :fermentable_inventory_log_entries, :brew_entry_id, :integer
	add_column :fermentable_inventory_log_entries, :recipe_id

	remove_column :hops_inventory_log_entries, :brew_entry_id, :integer
	add_column :hops_inventory_log_entries, :recipe_id

	remove_column :kit_inventory_log_entries, :brew_entry_id, :integer
	add_column :kit_inventory_log_entries, :recipe_id
  end
end
