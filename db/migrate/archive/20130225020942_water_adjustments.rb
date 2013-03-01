class WaterAdjustments < ActiveRecord::Migration
  def self.up

    add_index :audits, :user_id, :name => "index_audits_on_user_id"

    add_column :brew_entries,  :dilution_rate_mash, :integer
    add_column :brew_entries, :calcium_chloride_mash, :float    
    add_column :brew_entries, :gypsum_mash, :float    
    add_column :brew_entries, :epsom_salt_mash, :float    
    add_column :brew_entries, :table_salt_mash, :float    
    add_column :brew_entries, :baking_soda_mash, :float    
    add_column :brew_entries, :chalk_mash, :float    
    add_column :brew_entries, :citric_strength_mash, :integer  
    add_column :brew_entries, :lactic_strength_mash, :integer  
    add_column :brew_entries, :phosphoric_strength_mash, :integer  
    add_column :brew_entries, :same_water, :boolean  
    add_column :brew_entries, :dilution_rate_sparge, :integer  
    add_column :brew_entries, :calcium_chloride_sparge, :float    
    add_column :brew_entries, :gypsum_sparge, :float    
    add_column :brew_entries, :epsom_salt_sparge, :float    
    add_column :brew_entries, :table_salt_sparge, :float    
    add_column :brew_entries, :baking_soda_sparge, :float    
    add_column :brew_entries, :chalk_sparge, :float    
    add_column :brew_entries, :citric_volume_mash, :float    
    add_column :brew_entries, :lactic_volume_mash, :float    
    add_column :brew_entries, :phosphoric_volume_mash, :float    
    add_column :brew_entries, :citric_volume_sparge, :float    
    add_column :brew_entries, :citric_strength_sparge, :integer  
    add_column :brew_entries, :lactic_volume_sparge, :float    
    add_column :brew_entries, :lactic_strength_sparge, :integer  
    add_column :brew_entries, :phosphoric_volume_sparge, :float    
    add_column :brew_entries, :phosphoric_strength_sparge, :integer  

    add_column :brew_entry_logs, :bicarbonate, :float    
    add_column :brew_entry_logs, :calcium, :float    
    add_column :brew_entry_logs, :carbonate, :float    
    add_column :brew_entry_logs, :chloride, :float    
    add_column :brew_entry_logs, :fluoride, :float    
    add_column :brew_entry_logs, :iron, :float    
    add_column :brew_entry_logs, :magnesium, :float    
    add_column :brew_entry_logs, :nitrate, :float    
    add_column :brew_entry_logs, :nitrite, :float    
    add_column :brew_entry_logs, :pH, :float    
    add_column :brew_entry_logs, :potassium, :float    
    add_column :brew_entry_logs, :sodium, :float    
    add_column :brew_entry_logs, :sulfate, :float    
    add_column :brew_entry_logs, :total_alkalinity, :float    

	  
	  
	    add_index :fermentable_inventories, :fermentable_type_id, :name => "index_fermentable_inventories_on_fermentable_type_id"
  add_index :fermentable_inventories, :user_id, :name => "index_fermentable_inventories_on_user_id"

  add_index :fermentable_inventory_log_entries, :brew_entry_id, :name => "index_fermentable_inventory_log_entries_on_brew_entry_id"

  
    add_column :fermentable_types, :acidity_type, :string,  :default => "--- :base\n"

  add_index :hop_types, :user_id, :name => "index_hop_types_on_user_id"

  add_index :hops, :hop_type_id, :name => "index_hops_on_hop_type_id"
  add_index :hops, :recipe_id, :name => "index_hops_on_recipe_id"

  add_index :hops_inventories, :hop_type_id, :name => "index_hops_inventories_on_hop_type_id"
  add_index :hops_inventories, :user_id, :name => "index_hops_inventories_on_user_id"

  add_index :hops_inventory_log_entries, :hops_inventory_id, :name => "index_hops_inventory_log_entries_on_hops_inventory_id"
  add_index :hops_inventory_log_entries, :brew_entry_id, :name => "index_hops_inventory_log_entries_on_brew_entry_id"
  add_index :hops_inventory_log_entries, :user_id, :name => "index_hops_inventory_log_entries_on_user_id"


  add_index :ingredient_unit_preferences, :user_id, :name => "index_ingredient_unit_preferences_on_user_id"


  add_index :kit_inventory_log_entries, :kit_inventory_id, :name => "index_kit_inventory_log_entries_on_kit_inventory_id"
  add_index :kit_inventory_log_entries, :brew_entry_id, :name => "index_kit_inventory_log_entries_on_brew_entry_id"
  add_index :kit_inventory_log_entries, :user_id, :name => "index_kit_inventory_log_entries_on_user_id"

  add_index :kit_types, :user_id, :name => "index_kit_types_on_user_id"

  add_index :misc_ingredients, :recipe_id, :name => "index_misc_ingredients_on_recipe_id"

  add_index :recipe_user_shareds, :recipe_shared_id, :name => "index_recipe_user_shareds_on_recipe_shared_id"
  add_index :recipe_user_shareds, :user_id, :name => "index_recipe_user_shareds_on_user_id"

  add_index :recipes, :brew_entry_id, :name => "index_recipes_on_brew_entry_id"
  add_index :recipes, :style_id, :name => "index_recipes_on_style_id"
  add_index :recipes, :user_id, :name => "index_recipes_on_user_id"


  add_index :yeast_inventories, :user_id, :name => "index_yeast_inventories_on_user_id"
  add_index :yeast_inventories, :yeast_type_id, :name => "index_yeast_inventories_on_yeast_type_id"
  
  end

  def self.down

    remove_index :audits, :index_audits_on_user_id

    remove_column :brew_entries, :dilution_rate_mash
    remove_column :brew_entries, :calcium_chloride_mash
    remove_column :brew_entries, :gypsum_mash
    remove_column :brew_entries, :epsom_salt_mash
    remove_column :brew_entries, :table_salt_mash
    remove_column :brew_entries, :baking_soda_mash
    remove_column :brew_entries, :chalk_mash
    remove_column :brew_entries, :citric_strength_mash
    remove_column :brew_entries, :lactic_strength_mash
    remove_column :brew_entries, :phosphoric_strength_mash
    remove_column :brew_entries, :same_water
    remove_column :brew_entries, :dilution_rate_sparge
    remove_column :brew_entries, :calcium_chloride_sparge
    remove_column :brew_entries, :gypsum_sparge
    remove_column :brew_entries, :epsom_salt_sparge
    remove_column :brew_entries, :table_salt_sparge
    remove_column :brew_entries, :baking_soda_sparge
    remove_column :brew_entries, :chalk_sparge
    remove_column :brew_entries, :citric_volume_mash
    remove_column :brew_entries, :lactic_volume_mash
    remove_column :brew_entries, :phosphoric_volume_mash
    remove_column :brew_entries, :citric_volume_sparge
    remove_column :brew_entries, :citric_strength_sparge
    remove_column :brew_entries, :lactic_volume_sparge
    remove_column :brew_entries, :lactic_strength_sparge
    remove_column :brew_entries, :phosphoric_volume_sparge
    remove_column :brew_entries, :phosphoric_strength_sparge
    remove_column :brew_entries, :yeast_pitched_date

    
    remove_column :brew_entry_logs, :bicarbonate
    remove_column :brew_entry_logs, :calcium
    remove_column :brew_entry_logs, :carbonate
    remove_column :brew_entry_logs, :chloride
    remove_column :brew_entry_logs, :fluoride
    remove_column :brew_entry_logs, :iron
    remove_column :brew_entry_logs, :magnesium
    remove_column :brew_entry_logs, :nitrate
    remove_column :brew_entry_logs, :nitrite
    remove_column :brew_entry_logs, :pH
    remove_column :brew_entry_logs, :potassium
    remove_column :brew_entry_logs, :sodium
    remove_column :brew_entry_logs, :sulfate
    remove_column :brew_entry_logs, :total_alkalinity
   
  remove_index :fermentable_inventories, :index_fermentable_inventories_on_fermentable_type_id
  remove_index :fermentable_inventories, :index_fermentable_inventories_on_user_id

  remove_index :fermentable_inventory_log_entries, :index_fermentable_inventory_log_entries_on_recipe_id

  
    remove_column :fermentable_types, :acidity_type

  remove_index :hop_types, :index_hop_types_on_user_id

  remove_index :hops, :index_hops_on_hop_type_id
  remove_index :hops, :index_hops_on_recipe_id

  remove_index :hops_inventories, :index_hops_inventories_on_hop_type_id
  remove_index :hops_inventories, :index_hops_inventories_on_user_id

  remove_index :hops_inventory_log_entries, :index_hops_inventory_log_entries_on_hops_inventory_id
  remove_index :hops_inventory_log_entries, :index_hops_inventory_log_entries_on_brew_entry_id
  remove_index :hops_inventory_log_entries, :index_hops_inventory_log_entries_on_user_id


  remove_index :ingredient_unit_preferences, :index_ingredient_unit_preferences_on_user_id


  remove_index :kit_inventory_log_entries, :index_kit_inventory_log_entries_on_kit_inventory_id
  remove_index :kit_inventory_log_entries, :index_kit_inventory_log_entries_on_brew_entry_id
  remove_index :kit_inventory_log_entries, :index_kit_inventory_log_entries_on_user_id

  remove_index :kit_types, :index_kit_types_on_user_id

  remove_index :misc_ingredients, :index_misc_ingredients_on_recipe_id

  remove_index :recipe_user_shareds, :index_recipe_user_shareds_on_recipe_shared_id
  remove_index :recipe_user_shareds, :index_recipe_user_shareds_on_user_id

  remove_index :recipes, :index_recipes_on_brew_entry_id
  remove_index :recipes, :index_recipes_on_style_id
  remove_index :recipes, :index_recipes_on_user_id


  remove_index :yeast_inventories, :index_yeast_inventories_on_user_id
  remove_index :yeast_inventories, :index_yeast_inventories_on_yeast_type_id
  end
end
