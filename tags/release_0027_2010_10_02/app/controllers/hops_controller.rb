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

class HopsController < ApplicationController

  hobo_model_controller

  include AppSecurity
  include RecipesHelper

  auto_actions :all


	def update
		@hop = Hop.find(params[:id])


    if !@hop.recipe.updatable_by?(current_user) 
      #      flash[:error] = "Update fermentable - permission denied."
      #      update_details_and_hop( @hop )
      notifyattempt( request,"HopsController.update not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

        # Create log message before conversions applied.
    msg=""
    params[:hop].each_pair{ |key, value|
      msg += "#{key.capitalize} => #{value} "
    }


		#Do unit conversions if required.
    params[:hop][:weight] = BrewingUnits::value_for_storage( current_user.units.hops, params[:hop][:weight] ) if  params[:hop][:weight]

    ahop_use = :boil unless params[:hop][:minutes].nil?
    
    if params[:hop][:minutes] then  #Check if it is designated a dry hopped value
      begin
        if params[:hop][:minutes].upcase.first == "D"  # Convert from dried hop value
          params[:hop][:minutes] = -1000.0
          ahop_use = :dry_hop
        end
        if ( params[:hop][:minutes].upcase.first(7) == "HOP TEA" || # Convert from hop tea value
            params[:hop][:minutes].upcase.first(7) == "HT" ||
              params[:hop][:minutes].upcase.first(12) == "FRENCH PRESS" ||
              params[:hop][:minutes].upcase.first(12) == "FP" )
          params[:hop][:minutes] = -1000.0 
          ahop_use = :hop_tea
        end
      rescue # do nothing
      end
    end

    #@hop.hop_use = ahop_use
    @hop.hop_use = ahop_use.to_s  unless params[:hop][:minutes].nil?  #Only set if the minutes value is explicitly set

		if @hop.update_attributes(params[:hop])

      #Force reload of parent recipe record.
      # @hop.recipe.reload

      
      @hop.recipe.mark_update( "Hop [#{@hop.hop_type.name}] update: #{msg}", current_user)

			if request.xhr?
				# Route to correct update as specified or the whole screen if not.
				case params[:render]
				when "details_and_hop"
					update_details_and_hop( @hop )
        when "none"
          render( :nothing => true )
				else
          redirect_to  :action => 'edit', :controller => :recipes, :id =>@hop.recipe.id
				end
			else # Updated for a regualar post method.
				flash[:notice] = "Successfully updated recipe and fermentables."
				redirect unless @hop.update_permitted?
			end
		else
			render :action => 'edit'
		end
	end


end
