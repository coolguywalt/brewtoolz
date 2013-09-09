class HoboMigration5 < ActiveRecord::Migration
  def self.up
    add_column :yeast_types, :validated, :boolean
    add_column :yeast_types, :user_id, :integer
  end

  def self.down
    remove_column :yeast_types, :validated
    remove_column :yeast_types, :user_id
  end
end
