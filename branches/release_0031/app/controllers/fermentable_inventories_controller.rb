#    This file is part of Brewtools.
#
#    Brewtools is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Brewtools is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with Brewtools.  If not, see <http://www.gnu.org/licenses/>.
#
#    Copyright Chris Taylor, 2008, 2009, 2010 

class FermentableInventoriesController < ApplicationController

  hobo_model_controller

  auto_actions :all
  auto_actions_for :fermentable_inventory_log_entries,  :create


  def index
    hobo_index FermentableInventory.viewable_search(current_user, params[:search]).apply_scopes(:order_by => parse_sort_param(:name,:location,:source_date) )

    #@fermentable_types = FermentableType.paginate( :order => 'name', :page => params[:page], :per_page => 100 )

    #this = @fermentable_types
  end

  #  def delete
  #    @fermentable_inventory = FermentableInventory.find(params[:id])
  #    @fermentable_inventory.destroy
  #    redirect_to fermentable_inventories_path
  #  end

  #  def update
  #    @fermentable_inventory = FermentableInventory.find(params[:id])
  #    #Do unit conversions if required.
  #    params[:fermentable_inventory][:amount] = input_fermentable_weight( params[:fermentable_inventory][:amount] ) if  params[:fermentable_inventory][:amount]
  #    @fermentable_inventory.update_attributes(params[:fermentable_inventory])
  #    redirect_to fermentable_inventories_path
  #  end

  def show

    hobo_show

    if @log_entry.nil? or @log_entry.errors.count == 0 then
      @log_entry = FermentableInventoryLogEntry.new
      @log_entry.fermentable_inventory = this
    end
   
  end
end
