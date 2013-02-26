class AddYeastPitchDate < ActiveRecord::Migration
  def self.up
    add_column :brew_entries, :yeast_pitched_date, :date
  end

  def self.down
    remove_column :brew_entries, :yeast_pitched_date, :date
  end
end
