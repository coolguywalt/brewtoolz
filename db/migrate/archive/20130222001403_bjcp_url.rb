class BjcpUrl < ActiveRecord::Migration
  def self.up
	add_column :styles, :bjcp_url, :string 
	add_column :categories, :bjcp_url, :string 
  end

  def self.down
	remove_column :styles, :bjcp_url
	remove_column :categories, :bjcp_url
  end
end
