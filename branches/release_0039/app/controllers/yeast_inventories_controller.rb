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

class YeastInventoriesController < ApplicationController

  hobo_model_controller

  auto_actions :all


  def index
    hobo_index YeastInventory.viewable(current_user).apply_scopes(:search => [params[:search],:name,:comment,:location],
      :order_by => parse_sort_param(:name,:location,:source_date) )

  end

  def show

    hobo_show

    if @log_entry.nil? or @log_entry.errors.count == 0 then
      @log_entry = YeastInventoryLogEntry.new
      @log_entry.yeast_inventory = this
    end

  end

end
