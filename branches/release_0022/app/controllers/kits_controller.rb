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

class KitsController < ApplicationController

  include RecipesHelper

  hobo_model_controller

  auto_actions :all

  def update

    @kit = Kit.find(params[:id])


    unless @kit.recipe.updatable_by?(current_user)
      #      flash[:error] = "Update fermentable - permission denied."
      #      update_details_and_hop( @hop )
      notifyattempt( request,"KitController.update not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

		if @kit.update_attributes(params[:kit])

      # Create log message before conversions applied.
      msg=""
      params[:kit].each_pair{ |key, value|
        msg += "#{key.capitalize} => #{value} "
      }

      @kit.recipe.mark_update("Kit [#{@kit.kit_type.name}]  update: #{msg}", current_user)

			if request.xhr?
				# Route to correct update as specified or the whole screen if not.
				case params[:render]
				when "details_and_kit"
					update_details_and_kits(@kit.recipe)
        when "none"
          render( :nothing => true )
				else
          redirect_to  :action => 'edit', :controller => :recipes, :id =>@kit.recipe.id
				end
			else # Updated for a regualar post method.
				flash[:notice] = "Successfully updated recipe and kits."
				redirect unless @kit.update_permitted?
			end

		else
			render :action => 'edit'
		end

  end

end
