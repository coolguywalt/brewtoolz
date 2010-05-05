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

class MiscIngredientsController < ApplicationController

	hobo_model_controller
  include RecipesHelper
  include AppSecurity
	auto_actions :all

	def update

		@misc = MiscIngredient.find(params[:id])


    if !@misc.recipe.updatable_by?(current_user) 
      #      flash[:error] = "Update fermentable - permission denied."
      #      render_misc( @misc )
      notifyattempt( request,"MiscIngredientsController.update not from authorized user: #{current_user}")
      render( :nothing => true )

      return
    end

		#Do unit conversions if required.
		if( params[:misc_ingredient][:is_solid] ) then
			params[:misc_ingredient][:amount] = BrewingUnits::value_for_storage( current_user.units.volume, params[:misc_ingredient][:amount] ) if  params[:misc_ingredient][:amount]
		else
			params[:misc_ingredient][:amount] = input_hops_weight( params[:misc_ingredient][:amount] ) if  params[:misc_ingredient][:amount]
		end

		@misc.amount_l = params[:misc_ingredient][:amount] / @misc.recipe.volume
		params[:misc_ingredient].delete(:amount)

		if @misc.update_attributes(params[:misc_ingredient])

       @misc.recipe.mark_update( "Misc update: #{params}")

			if request.xhr?
				# Route to correct update as specified or the whole screen if not.
				case params[:render]
				when "misc"
					render_misc( @misc.recipe )
				else
          redirect_to  :action => 'edit', :controller => :recipes, :id =>@misc.recipe.id
				end
			else # Updated for a regualar post method.
				flash[:notice] = "Successfully updated recipe and fermentables."
				redirect unless @fermentable.update_permitted?
			end
		else
			render :action => 'edit'
		end
	end
end
