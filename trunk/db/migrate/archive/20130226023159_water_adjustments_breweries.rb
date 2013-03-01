class WaterAdjustmentsBreweries < ActiveRecord::Migration
  def self.up

    add_column :breweries, :bicarbonate, :float
    add_column :breweries, :calcium, :float
    add_column :breweries, :carbonate, :float
    add_column :breweries, :chloride, :float
    add_column :breweries, :fluoride, :float
    add_column :breweries, :iron, :float
    add_column :breweries, :magnesium, :float
    add_column :breweries, :nitrate, :float
    add_column :breweries, :nitrite, :float
    add_column :breweries, :pH, :float
    add_column :breweries, :potassium, :float
    add_column :breweries, :sodium, :float
    add_column :breweries, :sulfate, :float
    add_column :breweries, :total_alkalinity, :float
  end

  def self.down


    remove_column :breweries, :bicarbonate
    remove_column :breweries, :calcium
    remove_column :breweries, :carbonate
    remove_column :breweries, :chloride
    remove_column :breweries, :fluoride
    remove_column :breweries, :iron
    remove_column :breweries, :magnesium
    remove_column :breweries, :nitrate
    remove_column :breweries, :nitrite
    remove_column :breweries, :pH
    remove_column :breweries, :potassium
    remove_column :breweries, :sodium
    remove_column :breweries, :sulfate
    remove_column :breweries, :total_alkalinity
  end
end
