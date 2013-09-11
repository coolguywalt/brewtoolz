class ProdInventoryUpdates < ActiveRecord::Migration
  def self.up
	
    #remove_column :yeast_inventory_log_entries, :brew_entry_id 
	add_column :yeast_inventory_log_entries, :recipe_id, :integer
	add_column :yeast_inventory_log_entries, :yeast_id, :integer

	#remove_column :fermentable_inventory_log_entries, :brew_entry_id 
	add_column :fermentable_inventory_log_entries, :recipe_id, :integer
	add_column :fermentable_inventory_log_entries, :fermentable_type_id, :integer

	#remove_column :hops_inventory_log_entries, :brew_entry_id
	add_column :hops_inventory_log_entries, :recipe_id, :integer
	add_column :hops_inventory_log_entries, :hop_type_id, :integer

	#remove_column :kit_inventory_log_entries, :brew_entry_id
	add_column :kit_inventory_log_entries, :recipe_id, :integer
	add_column :kit_inventory_log_entries, :kit_type_id, :integer

	add_column :yeast_inventories, :balance, :float
	add_column :fermentable_inventories, :balance, :float
	add_column :hops_inventories, :balance, :float
	add_column :kit_inventories, :balance, :float
    
	add_column :yeast_inventory_log_entries, :yeast_id, :integer
	add_column :fermentable_inventory_log_entries, :fermentable_id, :integer
	add_column :hops_inventory_log_entries, :hop_id, :integer
	add_column :kit_inventory_log_entries, :kit_id, :integer

    # this needs to be populated.
    add_column :yeast_type, :cells_in_package, :float
    add_column :yeast_type, :isliquid, :boolean

    YeastInventory.update_all( "balance = amount" );
    FermentableInventory.update_all( "balance = amount" );
    HopsInventory.update_all( "balance = amount" );
    KitInventory.update_all( "balance = amount" );
  end

  def self.down
	#add_column :yeast_inventory_log_entries, :brew_entry_id, :integer
	remove_column :yeast_inventory_log_entries, :recipe_id
	remove_column :yeast_inventory_log_entries, :yeast_type_id

	#add_column :fermentable_inventory_log_entries, :brew_entry_id, :integer
	remove_column :fermentable_inventory_log_entries, :recipe_id
	remove_column :fermentable_inventory_log_entries, :fermentable_type_id

	#add_column :hops_inventory_log_entries, :brew_entry_id, :integer
	remove_column :hops_inventory_log_entries, :recipe_id
	remove_column :hops_inventory_log_entries, :hop_type_id

	#add_column :kit_inventory_log_entries, :brew_entry_id, :integer
	remove_column :kit_inventory_log_entries, :recipe_id
	remove_column :kit_inventory_log_entries, :kit_type_id

	remove_column :yeast_inventories, :balance
	remove_column :fermentable_inventories, :balance
	remove_column :hops_inventories, :balance
	remove_column :kit_inventories, :balance

	remove_column :yeast_inventory_log_entries, :yeast_id
	remove_column :fermentable_inventory_log_entries, :fermentable_id
	remove_column :hops_inventory_log_entries, :hop_id
	remove_column :kit_inventory_log_entries, :kit_id

	remove_column :yeast_type, :cells_in_package
	remove_column :yeast_type, :isliquid

  end
end
