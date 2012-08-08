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

class BrewEntryLogsController < ApplicationController

	hobo_model_controller

	auto_actions :all

	def show
		@brew_entry_log = BrewEntryLog.find(params[:id])

		redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry_log.brew_entry.id )
	end

	def edit
		logger.debug( "edit for BrewEntryLogsController")

		@brew_entry_log = BrewEntryLog.find(params[:id])
		@brew_entry_log.specific_gravity = BrewingUnits::value_for_display( current_user.units.gravity, @brew_entry_log.specific_gravity, 3) if @brew_entry_log.specific_gravity

		@this = @brew_entry_log
	end

	def update

		@brew_entry_log = BrewEntryLog.find(params[:id])

    unless @brew_entry_log.updatable_by?(current_user)
      #      flash[:error] = "Update - Permission denied."
      #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry_log.brew_entry.id )

      notifyattempt( request,"BrewEntryLogsController.update not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end


		@brew_entry_log.attributes = params[:brew_entry_log]

		if (params[:specific_gravity_refractometer] != "" && !@brew_entry_log.specific_gravity)
			# Updated gravity reading with refractometer reading.
			gravity_reading = BrewingUnits::refractomer_to_points(params[:specific_gravity_refractometer],@brew_entry_log.brew_entry.actual_og )

			logger.debug( "Refractometer conversion from #{params[:specific_gravity_refractometer]} to #{gravity_reading} points")
			@brew_entry_log.specific_gravity = gravity_reading
		else
			@brew_entry_log.specific_gravity = BrewingUnits::value_for_storage( current_user.units.gravity, @brew_entry_log.specific_gravity) if  @brew_entry_log.specific_gravity
		end

		logger.debug "specific gravity: #{@brew_entry_log.specific_gravity}"
		@brew_entry_log.specific_gravity = nil if @brew_entry_log.specific_gravity == ""


		# Translate parameters so that they take into consideration the input units.
		@brew_entry_log.temperature = BrewingUnits::value_for_storage( current_user.units.temperature, @brew_entry_log.temperature) if @brew_entry_log.temperature

		@brew_entry_log.save

		@this = @brew_entry_log # alias "@this" object

		redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry_log.brew_entry.id )
	end

end
