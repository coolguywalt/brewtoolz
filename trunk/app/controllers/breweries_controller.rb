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

class BreweriesController < ApplicationController

  hobo_model_controller

  auto_actions :all

	def update

		@brewery = Brewery.find(params[:id])
		@brewery.update_attributes(params[:brewery])

                # unit conversions
                brewery_params = params[:brewery]
                volume = current_user.units.volume
		@brewery.boiler_loses = BrewingUnits::value_for_storage( volume,
                    @brewery.boiler_loses ) if brewery_params[:boiler_loses]
		@brewery.capacity = BrewingUnits::value_for_storage( volume,
                    @brewery.capacity ) if brewery_params[:capacity]
		@brewery.evapouration_rate = BrewingUnits::value_for_storage(
                    volume, @brewery.evapouration_rate ) if
                        brewery_params[:boiler_loses]
		@brewery.mash_tun_capacity = BrewingUnits::value_for_storage(
                    volume, @brewery.mash_tun_capacity ) if
                        brewery_params[:mash_tun_capacity]
		@brewery.mash_tun_deadspace = BrewingUnits::value_for_storage(
                    volume, @brewery.mash_tun_deadspace ) if
                        brewery_params[:mash_tun_deadspace]
		@brewery.liquor_to_grist = BrewingUnits::value_for_storage(
                    current_user.units.liquor_to_grist,
                    @brewery.liquor_to_grist ) if
                        brewery_params[:liquor_to_grist]

			
		logger.debug "Saving brewery"
                @brewery.save

		if @brewery.isDefault
			# Set all other breweries to non default
			Brewery.update_all("isDefault = 0", "id != #{@brewery.id}" )
		end

		redirect_to :action => "show"
	end

	def create

		@brewery = Brewery.new(params[:brewery])

		if @brewery.save!
			flash[:notice] = "Successfully created recipe."
			redirect_to( url_for( :controller => 'breweries', :action => 'edit', :id => @brewery.id ))
		else
			flash[:error] =  @brewery.errors.full_messages {|u| u}.join(', ')
			redirect_to( :action => 'new' )
		end
	end

	def remove_brewery

		@brewery = Brewery.find(params[:id])

		Brewery.delete(params[:id])

		redirect_to url_for( :controller => 'breweries', :action => 'index' )

	end
  
  def index
    @breweries =  Brewery.paginate( :page => params[:page],
      :per_page   => 20,
      :conditions => "user_id = #{current_user.id}",
      :order => "name" )
  end

end
