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

class FermentablesController < ApplicationController

	hobo_model_controller
	include RecipesHelper
	include AppSecurity

	auto_actions :all


	def update
		@fermentable = Fermentable.find(params[:id])
		old_og = @fermentable.recipe.og

		if !@fermentable.recipe.updatable_by?(current_user)
			#      flash[:error] = "Update fermentable - permission denied."
			#      update_details_and_fermentable( @fermentable )

			notifyattempt( request,"FermentablesController.update not from authorized user: #{current_user}")
			render( :nothing => true )
			return
		end

		# Create log message before conversions applied.
		msg=""
		params[:fermentable].each_pair{ |key, value|
			msg += "#{key.capitalize} => #{value} "
		}

		#Do unit conversions if required.
		params[:fermentable][:points] = BrewingUnits::input_gravity( params[:fermentable][:points], current_user.units.gravity ) if  params[:fermentable][:points]
		params[:fermentable][:weight] = UnitsHelper::input_fermentable_weight( params[:fermentable][:weight], current_user ) if  params[:fermentable][:weight]

		if @fermentable.update_attributes(params[:fermentable])

			#Force reload of the recipe object
			@fermentable.recipe.reload

			new_og = @fermentable.recipe.og
			@fermentable.recipe.adjust_fixed_hops_for_change(1.0, new_og, old_og)

			@fermentable.recipe.mark_update("Fermentable [#{@fermentable.fermentable_type.name}] update: #{msg}", current_user)

			if request.xhr?
				# Route to correct update as specified or the whole screen if not.
				case params[:render]
				when "details_and_fermentable"
					update_details_and_fermentable( @fermentable )
				when "none"
					render( :nothing => true )
				else
					redirect_to  :action => 'edit', :controller => :recipes, :id =>@fermentable.recipe.id
				end
			else # Updated for a regualar post method.
				flash[:notice] = "Successfully updated recipe and fermentables."
				redirect unless @fermentable.update_permitted?
			end
		else
			update_errors
		end
	end
end
