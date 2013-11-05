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

class BrewEntriesController < ApplicationController

    hobo_model_controller
    include BrewEntriesHelper
    include AppSecurity
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TagHelper
    include Utils

    auto_actions :all


    def add_entry
        logger.debug "adding entry"

        @brew_entry = BrewEntry.find(params[:id])

        if !@brew_entry.updatable_by?(current_user) 
            #      flash[:error] = "Add entry - permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id )
            notifyattempt( request,"BrewEntriesController.add_entry not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end


        log_type_param = params[:type] || "observation"

        @brew_entry_log = BrewEntryLog.new
        @brew_entry_log.brew_entry = @brew_entry
        @brew_entry_log.log_date = Time.now
        @brew_entry_log.user = @brew_entry.user
        @brew_entry_log.log_type = log_type_param
        @brew_entry_log.rating = 30
        @brew_entry_log.specific_gravity = @brew_entry.min_log_sg
        @brew_entry_log.specific_gravity = @brew_entry.actual_og unless @brew_entry_log.specific_gravity

        @brew_entry_log.save

        logger.debug "new entry log id: #{@brew_entry_log.id}"

        redirect_to :controller => "brew_entry_logs", :action => "edit", :id =>@brew_entry_log.id
    end

    def  remove_brewlog_item
        @brew_entry_log = BrewEntryLog.find(params[:id])

        #    if !@brew_entry_log.updatable_by?(current_user)
        #      flash[:error] = "Update - Permission denied."
        #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id )
        #      return
        #    end

        @brew_entry = @brew_entry_log.brew_entry
        if !@brew_entry.updatable_by?(current_user) 
            #      flash[:error] = "Add entry - permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id )
            notifyattempt( request,"BrewEntriesController.remove_brewlog_item not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end


        BrewEntryLog.delete(params[:id])

        redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id )
    end

    def remove_brewentry_item
        @brew_entry = BrewEntry.find(params[:id])

        if !@brew_entry.updatable_by?(current_user) 
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id )
            notifyattempt( request,"BrewEntriesController.remove_brewentry_item not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        BrewEntry.delete(params[:id])

        redirect_to url_for( :controller => 'brew_entries', :action => 'index' )

    end

    def print
        @brew_entry = BrewEntry.find(params[:id])

    end


    def edit
        @this = BrewEntry.find(params[:id])

        if !@this.updatable_by?(current_user) 
            #      flash[:error] = "Current user can not edit this entry."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id )
            notifyattempt( request,"BrewEntriesController.edit not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        @this.actual_fg = BrewingUnits::value_for_display( current_user.units.gravity, @this.actual_fg, 3) if @this.actual_fg
        @this.actual_og = BrewingUnits::value_for_display( current_user.units.gravity, @this.actual_og, 3) if @this.actual_og
        @this.pitching_temp = BrewingUnits::value_for_display( current_user.units.temperature, @this.pitching_temp) if @this.pitching_temp
        @this.volume_to_ferementer = BrewingUnits::value_for_display( current_user.units.volume, @this.volume_to_ferementer) if @this.volume_to_ferementer
    end

    def update

        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user)
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        @brew_entry.update_attributes(params[:brew_entry])

        # Translate parameters so that they take into consideration the input units.
        @brew_entry.actual_fg = BrewingUnits::value_for_storage( current_user.units.gravity, @brew_entry.actual_fg) if params[:actual_fg]
        @brew_entry.actual_og = BrewingUnits::value_for_storage( current_user.units.gravity, @brew_entry.actual_og) if params[:actual_og]
        @brew_entry.pitching_temp = BrewingUnits::value_for_storage( current_user.units.temperature, @brew_entry.pitching_temp) if params[:pitching_temp]
        @brew_entry.volume_to_ferementer = BrewingUnits::value_for_storage( current_user.units.volume, @brew_entry.volume_to_ferementer) if params[:volume_to_ferementer]

        valid = @brew_entry.save
        logger.debug("++brew entry update valid:#{valid}")

        if !valid then
            #Error saving this.
            update_errors
            return
        end


        if params[:render] then
            case params[:render]
            when "update_all_brewday"
                update_all_brewday
            when "update_values_div"
                update_values_div
            else
                updated_values_and_recipe_div
            end
        else
            redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id )
        end
    end

    def whatsbrewing
        # Process the search filter
        if params[:brewlog_filter]
            search_filter = "( recipes.name LIKE '%#{params[:brewlog_filter]}%' )"
            session[:whatsbrewingSearchFilter] = search_filter
            logger.debug "Updated search filter: #{search_filter}"
        else
            session[:whatsbrewingSearchFilter] = nil
        end


        #Check sort order updates
        if params[:"sort_order"]
            case params[:"sort_order"]
            when "Name"
                new_order = "recipes.name, brew_date DESC"
            when "Date"
                new_order = "brew_date DESC, recipes.name"
            when "Rating"
                new_order = "brew_entries.rating DESC, recipes.name"
            else
                new_order = ""
            end


            session[:whatsbrewingOrderBy] = new_order
            logger.debug "Updated style selection: #{new_order}"
        end


        @brew_entries = whatsbrewing_brewlog_list()

        respond_to do |format|
            format.html
            format.js {
                render :update do |page|
                page.replace_html 'brewlog_collecion_div', :partial => 'shared/brewlog_collection', :object => @brew_entries
                end
            }
        end
    end


    def update_from_recipe
        logger.debug "updating from recipe"

        @brew_entry = BrewEntry.find(params[:id]) 

        if !@brew_entry.updatable_by?(current_user)
            #      flash[:error] = "Current user can not edit this entry."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_from_recipe not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end


        @current_recipe =@brew_entry.recipe

        @current_brew_entry_actual_recipe =  @brew_entry.actual_recipe

        # Delete the old recipe.
        @current_brew_entry_actual_recipe.destroy if @current_brew_entry_actual_recipe

        default_brewery = Brewery.default_brewery(current_user)
        logger.debug "Default brewery: #{default_brewery}"

        #Deep copy of recipe to new brew_entry
        @brew_entry.copy_to_actual_recipe( @current_recipe, default_brewery, current_user )

        @brew_entry.save

        logger.debug "updated for entry id: #{@brew_entry.id}"

        redirect_to :controller => "brew_entries", :action => "show", :id =>@brew_entry.id
    end

    def brewday
        logger.debug "brewday"

        @brew_entry = BrewEntry.find(params[:id])
        @this = @brew_entry
    end

    def brewdayrecipe
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user)

            notifyattempt( request,"BrewEntriesController.brewdayrecipe not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end


        @this = @brew_entry
        @recipe = @brew_entry.actual_recipe

    end

    def brewdaymashsparge
        @brew_entry = BrewEntry.find(params[:id])

        @this = @brew_entry


    end


    def brewdayyeast
        @brew_entry = BrewEntry.find(params[:id])

        @this = @brew_entry


    end


    #	def update_volume
    #		@brew_entry = BrewEntry.find(params[:id])
    #
    #    unless @brew_entry.updatable_by?(current_user) || !request.xhr?
    #      #      flash[:error] = "Update - Permission denied."
    #      #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
    #      notifyattempt( request,"BrewEntriesController.update_volume not from authorized user: #{current_user}")
    #      render( :nothing => true )
    #      return
    #    end
    #
    #		new_volume = params[:volume]
    #		new_volume = BrewingUnits::input_recipe_vol( new_volume, current_user.units.volume )
    #
    #		@brew_entry.volume_to_ferementer = new_volume
    #		@brew_entry.save
    #
    #
    #    if params[:render] then
    #      case params[:render]
    #      when "update_all_brewday"
    #        update_all_brewday
    #      else
    #        updated_values_and_recipe_div
    #      end
    #    else
    #      updated_values_and_recipe_div
    #    end
    #	end


    def update_mash_lose
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_volume not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        new_volume = params[:mash_dead_space]
        new_volume = BrewingUnits::input_recipe_vol( new_volume, current_user.units.volume )

        @brew_entry.mash_dead_space = new_volume
        @brew_entry.save


        if params[:render] then
            case params[:render]
            when "update_all_brewday"
                update_all_brewday
            else
                updated_values_and_recipe_div
            end
        else
            updated_values_and_recipe_div
        end
    end

    def update_evaporation_rate
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_volume not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        @brew_entry.evaporation_rate = params[:evaporation_rate]
        @brew_entry.save


        if params[:render] then
            case params[:render]
            when "update_all_brewday"
                update_all_brewday
            else
                updated_values_and_recipe_div
            end
        else
            updated_values_and_recipe_div
        end
    end

    def update_boil_time
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_volume not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        @brew_entry.boil_time = params[:boil_time]
        @brew_entry.save


        if params[:render] then
            case params[:render]
            when "update_all_brewday"
                update_all_brewday
            else
                updated_values_and_recipe_div
            end
        else
            updated_values_and_recipe_div
        end
    end


    def update_boil_time
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_volume not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        @brew_entry.boil_time = params[:boil_time]
        @brew_entry.save


        if params[:render] then
            case params[:render]
            when "update_all_brewday"
                update_all_brewday
            else
                updated_values_and_recipe_div
            end
        else
            updated_values_and_recipe_div
        end
    end

    def update_efficency
        @brew_entry = BrewEntry.find(params[:id]) || !request.xhr?
        return unless @brew_entry.actual_recipe

        unless @brew_entry.updatable_by?(current_user)
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_efficency not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        new_efficiency = params[:recipe][:efficency]

        @brew_entry.actual_recipe.efficency = new_efficiency
        unless @brew_entry.actual_recipe.save then
            #@brew_entry.errors[:base] << 
            @recipe = @brew_entry.actual_recipe
            update_errors
            return
        end


        if params[:render] then
            case params[:render]
            when "update_all_brewday"
                update_all_brewday
            else
                updated_values_and_recipe_div
            end
        else
            updated_values_and_recipe_div
        end
    end

    def update_conversion
        @brew_entry = BrewEntry.find(params[:id])
        return unless @brew_entry.actual_recipe


        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_conversion not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        new_conversion = params[:conversion]

        @brew_entry.mash_conversion = new_conversion
        @brew_entry.save

        update_all_brewday
    end



    def update_mashsparge
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_mashsparge not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        @brew_entry.update_attributes(params[:brew_entry])

        if @brew_entry.same_water # sparge additions should reflect mash
            if params[:brew_entry][:same_water] # just checked; do reflection
                @brew_entry.dilution_rate_sparge = @brew_entry.dilution_rate_mash
                BrewEntry.salts.keys.each do |salt|
                    @brew_entry.send( "#{salt}_sparge=",
                                     @brew_entry.send("#{salt}_mash") /
                                     @brew_entry.mash_water *
                                     @brew_entry.total_spargewater )
                end
                BrewEntry.acids.keys.each do |acid|
                    @brew_entry.send( "#{acid}_volume_sparge=",
                                     @brew_entry.send("#{acid}_volume_mash") /
                                     @brew_entry.mash_water *
                                     @brew_entry.total_spargewater )
                    @brew_entry.send( "#{acid}_strength_sparge=",
                                     @brew_entry.send("#{acid}_strength_mash") )
                end
            else                # not just checked; only mirror changed fields
                params[:brew_entry].keys.each do |mash_field|
                    match_data = /(.*)_mash$/.match mash_field
                    if !match_data.nil?
                        if match_data[1] == 'dilution_rate'
                            @brew_entry.dilution_rate_sparge =
                                @brew_entry.dilution_rate_mash
                        else
                            @brew_entry.send( "#{match_data[1]}_sparge=",
                                             @brew_entry.send(mash_field) /
                                             @brew_entry.mash_water *
                                             @brew_entry.total_spargewater )
                        end
                    end
                end
            end
        end

        @brew_entry.save

        case params[:render]
        when "mash"
            render(:update) { |page|
                page.replace_html 'mash_details_div', :partial => 'mash_details', :object => @brew_entry
                page << "if( $('sparge_details_div') ) {"
                page.replace_html 'sparge_details_div', :partial => 'spargewater', :object => @brew_entry
                page << "}"
            }
        when "water"
            render(:update) { |page|
                page.replace_html 'water_details_div', :partial => 'water_details', :object => @brew_entry
            }

        else
            render(:update) { |page|
                page.replace_html 'sparge_details_div', :partial => 'spargewater', :object => @brew_entry
            }
        end

    end

    def update_date_entry
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_date_entry not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        @brew_entry.update_attributes(params[:brew_entry])
        @brew_entry.save

        render(:update) { |page|
            page.replace_html 'dates_div', :partial => 'dates', :object => @brew_entry
        }

    end

    def update_colour
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_colour not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        new_colour = params[:colour]

        @brew_entry.actual_colour = new_colour
        @brew_entry.save

        update_values_div

    end

    def update_og
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_og not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        new_og = params[:og]
        new_og = BrewingUnits::input_gravity( new_og, current_user.units.gravity )

        @brew_entry.actual_og = new_og
        @brew_entry.save

        update_values_div

    end

    def update_fg
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )

            notifyattempt( request,"BrewEntriesController.update_fg not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        new_fg = params[:fg]
        new_fg = BrewingUnits::input_gravity( new_fg, current_user.units.gravity )

        @brew_entry.actual_fg = new_fg
        @brew_entry.save

        update_values_div

    end

    def update_comment
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #      flash[:error] = "Update - Permission denied."
            #      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_comment not from authorized user: #{current_user}")
            render( :nothing => true )
            return
        end

        @brew_entry.update_attributes(params[:brew_entry])

        @brew_entry.save

        if request.xhr?
            render :text =>  simple_format( h(@brew_entry.comment)  )
        end

    end


    def update_brewery
        @brew_entry = BrewEntry.find(params[:id])

        unless @brew_entry.updatable_by?(current_user) || !request.xhr?
            #		      flash[:error] = "Update - Permission denied."
            #		      redirect_to url_for( :controller => 'brew_entries', :action => 'show', :id => @brew_entry.id  )
            notifyattempt( request,"BrewEntriesController.update_brewery not from authorized user: #{current_user}")

            render(:nothing => true)
            return
        end


        @new_brewery = Brewery.find(params[:brewery_id])

        @brew_entry.setbrewery( @new_brewery )
        @brew_entry.save

        update_values_div

    end

    def update_invusage

        inv = :fermentable_inventory_log_entry if params[:fermentable_inventory_log_entry]
        inv = :hops_inventory_log_entry if params[:hops_inventory_log_entry]
        inv = :yeast_inventory_log_entry if params[:yeast_inventory_log_entry]
        inv = :kit_inventory_log_entry if params[:kit_inventory_log_entry]

        @ingr_type = inv.to_s.gsub("_inventory_log_entry", "")
        return unless inv #Not a know inventory type.

        @inv_item = Object.const_get(inv.to_s.classify).find(params[:id])
        return if @inv_item.nil? #Could not find the inventory item.

        @amount = params[inv][:amount]

        process_inv_usage
    end

    def all_from_inv
        @ingr_type = params[:inv_type].gsub( "hop", "hops" ) 

        inv_item_txt = @ingr_type + "_inventory_log_entry"
        @inv_item = Object.const_get(inv_item_txt.classify).find(params[:inv_item_id])
        return if @inv_item.nil?
        
        @amount = params[:amount_needed]
        
        process_inv_usage

    end

    def update_all_from_inventory
        return unless @brew_entry = BrewEntry.find(params[:id]) 
        allocate_for_type("fermentable")
        allocate_for_type("hops")
        allocate_for_type("kit")
        allocate_for_type("yeast")

        #Response
        render(:update) { |page|
            page.replace_html "inv_usage_div", :partial => "inventory_page"
        }
    end


    def update_all_for_type
        
        return unless @inv_type = params[:inv_type]
        @ingr_type = @inv_type.gsub('hop','hops')
        return unless @brew_entry = BrewEntry.find(params[:id]) 

        allocate_for_type( @ingr_type )

        #Response.
        return unless @inventory_list = current_user.send(@ingr_type + "_inventories").not_spent
        
        case @ingr_type
        when "hops"
            @units = BrewingUnits::units_for_display( current_user.units.hops )
            @ingr_list = @brew_entry.actual_recipe.hops.type_minutes 
        when "fermentable"
            @units =  BrewingUnits::units_for_display( current_user.units.fermentable )
            @ingr_list = @brew_entry.actual_recipe.fermentables.list
        else
            @units = ""
            @ingr_list = @brew_entry.actual_recipe.send(@ingr_type).list
        end

        @ingr = @ingr_list.first
        @inv_type = @ingr_type.gsub('hops','hop')
        
        render(:update) { |page|
            page.replace_html @inv_type.gsub('hops','hop') + "_inv_list_edit_div", :partial => "inventory_list_edit"
            page.replace_html @inv_type.gsub('hops','hop') + "_inv_usage_edit", :partial => "inventory_edit"
            page.replace_html 'errors_div', :partial => 'errors'
        }
    end 


    def allocate_for_type( ingr_type )
        #Iterate through ingredients list.
        @ingr_list = @brew_entry.actual_recipe.send(ingr_type.pluralize).list

        @ingr_list.each do |ingr|

            #Allocate from inventory item.
            #-- Check for an existing allocation.
            @inv_item = ingr.log_entries.first
            logger.debug "@inv_item: #{@inv_item}"

            unless @inv_item then
                #Look for matching inventory item.
                matched_inventory = ingr.ingr_type.inventories.not_spent.oldestfirst.find(:all, :conditions => ["user_id = ?", current_user.id] ).first
                logger.debug "Matched inventory: #{matched_inventory}"

                if matched_inventory then
                    #-- Create an assoicated log entry that matches the new hop type and amount.
                    invent_log_type_txt = ingr_type + "_inventory_log_entry"
                    invent_log_class =  Object.const_get( invent_log_type_txt.classify )

                    @inv_item = invent_log_class.create do |inv|
                        inv.inventory = matched_inventory
                        inv.recipe = @brew_entry.actual_recipe
                        inv.amount = 0.0
                        inv.ingr = ingr
                        inv.ingr_type = ingr.ingr_type
                    end
                end
            end

            if @inv_item then
                #-- Match aa for hop type and change target amount accordingly.
                if( ingr_type == "hops" ) then
                    new_amount = Utils.roundup(ingr.weight(@inv_item.inventory.aa))
                    ingr.aa = @inv_item.inventory.aa
                    ingr.save
                else
                    new_amount = Utils.roundup(ingr.amount) 
                end

                #-- Calculate the amount that needs to come out of the inventory.
                diff_amount = new_amount - @inv_item.amount  

                if diff_amount > @inv_item.inventory.balance then
                    # -- Adjust the amount if it overruns the inventory amount.
                    new_amount = @inv_item.inventory.balance
                    diff_amount = new_amount - @inv_item.amount  
                end  
                logger.debug "++ Allocate all from inv: new_amount:#{new_amount}, diff_amount:#{diff_amount}"

                # -- Update the inventory allocation, and the inventory balance.
                @inv_item.amount = new_amount
                is_valid = @inv_item.save

                if is_valid then
                    @inv_item.inventory.balance -= diff_amount
                    is_valid = @inv_item.inventory.save
                end
            end
        end


    end


    def process_inv_usage
        
        @ingr = @inv_item.ingr

        if @ingr_type == "hops" then
            # see if ingr is > 15 min hop addition and is the aa% the different?
            if (@ingr.minutes > 15.0) and (@ingr.aa != @inv_item.hops_inventory.aa) then
                # is there already a allocation to this item
                if @ingr.log_entries.count() > 0 then
                    #cap current ingredient to the current allocation
                    allocated_from_inventory = @ingr.log_entries.sum(:amount)

                    if( allocated_from_inventory > 0.0 ) then
                        cur_weight = @ingr.weight
                        @ingr.weight = allocated_from_inventory
                        @ingr.save

                        #create a new recipe ingredient
                        new_ingr = @ingr.clone
                        new_ingr.weight = cur_weight - allocated_from_inventory
                        new_ingr.save
                        @ingr = new_ingr

                        #assign this inventory item to it
                        @inv_item.ingr = new_ingr
                        @inv_item.save
                    else
                        @ingr.weight = cur_weight
                        @ingr.save
                    end
                end
            end
        end

        old_amount = @inv_item.amount
        @inv_item.amount = @amount 

        if is_valid = @inv_item.save
            @inv_type = @inv_item.send("#{@ingr_type}_inventory") 
            @inv_type.balance -= ( @amount.to_f - old_amount )
            is_valid &= @inv_type.save
        end

        #If this is a hop type updated, change the hop aa% entry to align with inventory item.
        if (@ingr_type == "hops") and (@ingr.minutes > 15.0) and (@inv_type.aa != @ingr.aa)
            @ingr.aa = @inv_type.aa
            @ingr.save
            #Hop.update_all( "aa = #{@inv_type.aa}", 
            #               ['recipe_id = ? and hop_type_id = ?', @inv_item.recipe, @inv_type.hop_type ] ) 
        end

        #Render updates 
        #Find the brew_entry
        @brew_entry = @inv_item.recipe.brew_entry

        return if @brew_entry.nil?  # Could not navigate to the brew entry.

        if is_valid then
            # ingr_list = @inv_item.recipe.send(@ingr_type.pluralize).list
            if @ingr_type == "hops"
                @ingr_list = @inv_item.recipe.hops.type_minutes 
            else
                @ingr_list = @inv_item.recipe.send(@ingr_type.pluralize).list
            end
            
            case @ingr_type
                when "hops"
                    @units = BrewingUnits::units_for_display( current_user.units.hops )
                when "fermentable"
                    @units =  BrewingUnits::units_for_display( current_user.units.fermentable )
                else
                    @units = ""
            end

            @inv_type = @ingr_type.gsub('hops','hop')

            render(:update) { |page|
                page.replace_html @inv_type + "_inv_list_edit_div", :partial => "inventory_list_edit"
                page.replace_html @inv_type + "_inv_usage_edit", :partial => "inventory_edit"
                page.replace_html 'errors_div', :partial => 'errors'
            }
        else
            update_errors
        end
    end
#        @inv_type = @inv_item.send(inv_txt)
#        inv_item_txt = @ingr_type + "_inventory_log_entry"
#        inv_txt = ingr_txt + "_inventory"
#        logger.debug "++all_from_inv: could not find inv_item" if @inv_item.nil? || @inv_type.nil?
#        return if @inv_item.nil? || @inv_type.nil? #Could not find the inventory item.
#
#
#        old_amount = @inv_item.amount
#        @inv_item.amount = params[:amount_needed].to_f 
#        @inv_item.amount = @inv_type.balance if @inv_type.balance < (@inv_item.amount - old_amount) 
#        
#        work_out_complicated_multi_hop_inventory_usage_scenario_with_different_aa_for_bittering
#
#        if is_valid = @inv_item.save
#            @inv_type.balance -= (@inv_item.amount - old_amount )
#            is_valid &= @inv_type.save
#        end
#
#        #If this is a hop type updated, change all hop aa% entries to align with inventory item.
#        if ingr_txt == "hops"
#            @inv_item.hop.aa = @inv_type.aa
#            @inv_item.hop.save
#            #Hop.update_all( "aa = #{@inv_type.aa}", 
#            #               ["recipe_id = ? and hop_type_id = ?", @inv_item.recipe, @inv_type.hop_type ] ) 
#        end
#
#        #Render updates 
#        #Find the brew_entry
#        @brew_entry = @inv_item.recipe.brew_entry
#        return if @brew_entry.nil?  # Could not navigate to the brew entry.
#
#        if is_valid then
#            ingr_type = params[:inv_type].gsub( "hop", "hops" )
#            if ingr_txt == "hops"
#                ingr_list = @inv_item.recipe.hops.unique_type
#            elsif
#                ingr_list = @inv_item.recipe.send(ingr_type.pluralize).list
#            end
#
#            @inv_type = ingr_txt
#            @ingr = @inv_item.ingr
#
#            render(:update) { |page|
#                #page.replace_html "#{ingr_type}invuse_div",
#                #    :partial => 'inventory_usage_list',
#                #    :locals => { :inv_type => ingr_type.gsub("hops","hop"), :units => ferm_weight_units, 
#                #         :ingr_list => ingr_list,
#                #         :recipe => @inv_item.recipe }
#                page.replace_html ingr_type.gsub('hops','hop') + "_inv_usage_edit", :partial => "inventory_edit"
#                page.replace_html 'errors_div', :partial => 'errors'
#            }
#        else
#            update_errors
#        end
#    end

    def loadyeasttab
        @brew_entry = BrewEntry.find(params[:id])
        render :partial => 'yeastcalc', :object => @brew_entry
    end

    def loadwatertab
        @brew_entry = BrewEntry.find(params[:id])
        render :partial => 'water', :object => @brew_entry
    end

    def loadmashtab
        @brew_entry = BrewEntry.find(params[:id])
        render :partial => 'mash', :object => @brew_entry
    end

    def loadspargetab
        @brew_entry = BrewEntry.find(params[:id])
        render :partial => 'sparge', :object => @brew_entry
    end

    def loadshoppinglist
        @brew_entry = BrewEntry.find(params[:id])
        render :partial => 'shopping_list', :object => @brew_entry
    end

    def loadinventoryuse
        @brew_entry = BrewEntry.find(params[:id])
        render :partial => 'inventory_page'
    end

    def inventory_list
        return unless @brew_entry = BrewEntry.find(params[:id]) 
        return unless @inv_type = params[:inv_type]

        # Get the inventory list of this type of ingredient for this user.  May be used for substitutions.
        return unless @inventory_list = current_user.send(@inv_type.gsub("hop","hops") + "_inventories").not_spent
    end

    def inventory_edit

        return unless @brew_entry = BrewEntry.find(params[:id])
        @inv_type = params[:inv_type]
        return unless @ingr = @brew_entry.actual_recipe.send(@inv_type.pluralize).find(params[:ingr_id])

        # Automatically renders inventory_edit.erb
    end

    def substitute
        
        @inv_type = params[:invtype] 
        @ingr_type = @inv_type.gsub('hop','hops')

        ingr_id = params[:ingrid]
        ingr_type_txt = @inv_type 
        return unless @ingr = Object.const_get(ingr_type_txt.classify).find(ingr_id) 
        
        invent_id = params[:id]
        invent_type_txt = @ingr_type + "_inventory"
        return unless @invent = Object.const_get(invent_type_txt.classify).find(invent_id) 

        #Delete current log entries associated with the item.
        @ingr.log_entries.each do |log_entry|
            #Add back to the inventory.
            log_entry.inventory.balance += log_entry.amount
            log_entry.inventory.save

            #Delete this item.
            log_entry.delete
        end 

        #Realign ingredient type to the inventory type.
        @ingr.ingr_type = @invent.invent_type
        if @ingr_type == "hops"
            @ingr.aa = @invent.aa
        end
        is_valid = @ingr.save

        if is_valid then
            #Create an assoicated log entry that matches the new hop type and amount.
            invent_log_type_txt = @ingr_type + "_inventory_log_entry"
            invent_log_class =  Object.const_get( invent_log_type_txt.classify )

            @inv_item = invent_log_class.create do |inv|
                inv.inventory = @invent
                inv.recipe = @ingr.recipe
                inv.amount = 0.0
                inv.ingr = @ingr
                inv.ingr_type = @ingr.ingr_type
            end

            #Allocate from the inventory.
            new_amount = @invent.balance > Utils.roundup(@ingr.amount) ? Utils.roundup(@ingr.amount) : @invent.balance

            @inv_item.amount = new_amount
            is_valid = @inv_item.save

            if is_valid then
                @invent.balance -= new_amount
                is_valid = @invent.save
            end
        end

        #Render updates 
        @brew_entry = @inv_item.recipe.brew_entry

        return if @brew_entry.nil?  # Could not navigate to the brew entry.

        if is_valid then
            if @ingr_type == "hops"
                @ingr_list = @inv_item.recipe.hops.type_minutes 
            else
                @ingr_list = @inv_item.recipe.send(@ingr_type).list
            end
            
            case @ingr_type
                when "hops"
                    @units = BrewingUnits::units_for_display( current_user.units.hops )
                when "fermentable"
                    @units =  BrewingUnits::units_for_display( current_user.units.fermentables )
                else
                    @units = ""
            end

            @inv_type = @ingr_type.gsub('hops','hop')

            render(:update) { |page|
                page.replace_html @inv_type + "_inv_list_edit_div", 
                    :partial => "inventory_list_edit"
                page.replace_html @inv_type + "_inv_usage_edit", :partial => "inventory_edit"
                page.replace_html 'errors_div', :partial => 'errors'
            }
        else
            update_errors
        end
    end

    private

    def updated_values_and_recipe_div

        #Format the volume field
        str = "%01.#{2}f" % @brew_entry.volume_to_ferementer

        render(:update) { |page|
            page.replace_html 'values_div', :partial => 'values'
            page.replace_html 'errors_div', :partial => 'errors' 

            #Update the span the holds the volume to ferementer
            page[:volume_to_ferementer_s].innerHTML = str

            if @brew_entry.actual_recipe then
                page.replace_html 'brewday_recipe_details_div', :partial => 'shared/recipe_view_detailed', :object => @brew_entry.actual_recipe
            end
        }
    end

    def update_all_brewday
        render(:update) { |page|
            page.replace_html 'recipevalues_div', :partial => 'recipe_values'
            page.replace_html 'preboilvalues_div', :partial => 'preboil_values'
            page.replace_html 'postboilvalues_div', :partial => 'postboil_values'
            page.replace_html 'brewday_recipe_details_div', :partial => 'shared/recipe_view_detailed', :object => @brew_entry.actual_recipe
            page.replace_html 'errors_div', :partial => 'errors' 
            page << "if( $('brewday_yeast_details_div') ) {"
            page.replace_html 'brewday_yeast_details_div', :partial => 'yeastdetails'
            page << "}"
            page << "if( $('mash_details_div') ) {"
            page.replace_html 'mash_details_div', :partial => 'mash_details'
            page << "}"
            page << "if( $('sparge_details_div') ) {"
            page.replace_html 'sparge_details_div', :partial => 'spargewater', :object => @brew_entry
            page << "}"
        }

    end

    def update_values_div
        # Updating the brewlog page after updates

        #Format the volume field
        str = "%01.#{2}f" % @brew_entry.volume_to_ferementer

        render(:update) { |page|
            page.replace_html 'values_div', :partial => 'values'
            page.replace_html 'errors_div', :partial => 'errors' 

            #Update the span the holds the volume to ferementer
            page[:volume_to_ferementer_s].innerHTML = str
        }

    end


    def update_errors
        render(:update) { |page|
            page.replace_html 'errors_div', :partial => 'errors' }
    end
end
