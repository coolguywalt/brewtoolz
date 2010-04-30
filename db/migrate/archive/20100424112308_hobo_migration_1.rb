class HoboMigration1 < ActiveRecord::Migration
  def self.up
    add_column :kit_types, :name, :string
    add_column :kit_types, :points, :float
    add_column :kit_types, :ibus, :float
    add_column :kit_types, :colour, :float
    add_column :kit_types, :volume, :float
    add_column :kit_types, :weight, :float
    add_column :kit_types, :description, :text
    
    add_column :kits, :quantity, :float
    add_column :kits, :kit_type_id, :integer
  end

  def self.down
    remove_column :kit_types, :name
    remove_column :kit_types, :points
    remove_column :kit_types, :ibus
    remove_column :kit_types, :colour
    remove_column :kit_types, :volume
    remove_column :kit_types, :weight
    remove_column :kit_types, :description
    
    remove_column :kits, :quantity
    remove_column :kits, :kit_type_id
  end
end
