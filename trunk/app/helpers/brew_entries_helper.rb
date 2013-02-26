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

module BrewEntriesHelper
  include RecipeCalcs


	$GRAIN_ABSORBTION = 1.3      # kg/l
	$GRAIN_DISPLACEMENT = 0.67   # kg/l

  #  def ajax_ferment_volume_editor( entry )
  #		ajax_edit_field( "volume",
  #			BrewingUnits::values_array_for_display( current_user.units.volume, entry.volume_to_ferementer, 2 ),
  #			"volume_to_ferementer",
  #			url_for(  :controller => "brew_entries", :action => :update, :id => entry.id, :render => "update_all_brewday" ), "Update Volume" )
  #	end

  def ajax_ferment_volume_editor( entry )
    #		ajax_edit_field( "volume",
    #			BrewingUnits::values_array_for_display( current_user.units.volume, entry.volume_to_ferementer, 2 ),
    #			"volume_to_ferementer",
    #			url_for(  :controller => "brew_entries", :action => "update", :id => entry.id, :render => "update_all_brewday" ), "Update Volume" )
    #
    ajax_edit_field2( entry, "volume_to_ferementer",
			{ :action => :update, :controller => :brew_entries, :id => entry.id, :render => "update_values_div" },
			BrewingUnits::values_array_for_display( current_user.units.volume, entry.volume_to_ferementer, 2 ),
      "Update Volume" )

	end

    def ajax_brewday_ferment_volume_editor( entry )
    #		ajax_edit_field( "volume",
    #			BrewingUnits::values_array_for_display( current_user.units.volume, entry.volume_to_ferementer, 2 ),
    #			"volume_to_ferementer",
    #			url_for(  :controller => "brew_entries", :action => "update", :id => entry.id, :render => "update_all_brewday" ), "Update Volume" )
    #
    ajax_edit_field2( entry, "volume_to_ferementer",
			{ :action => :update, :controller => :brew_entries, :id => entry.id, :render => "update_all_brewday" },
			BrewingUnits::values_array_for_display( current_user.units.volume, entry.volume_to_ferementer, 2 ),
      "Update Volume" )

	end

  def ajax_brewday_mash_efficency_editor( entry )

    eff = 75.0
    eff = entry.therecipe.efficency if entry.therecipe.efficency

    ajax_edit_field( "efficency",
      [decimal(eff)],
			"efficency",
			url_for(  :controller => "brew_entries", :action => :update_efficency, :id => entry.id, :render => "update_all_brewday" ), "Update Efficency" )
	end

  def ajax_brewday_mash_lose_editor( entry )
#    ajax_edit_field( "mash_lose",
#			BrewingUnits::values_array_for_display( current_user.units.volume, entry.mash_dead_space, 2 ),
#			"mash_dead_space",
#			url_for(  :controller => "brew_entries", :action => :update_mash_lose, :id => entry.id, :render => "update_all_brewday" ), "Update Mash Lose" )
#

        ajax_edit_field2( entry, "mash_dead_space",
			{ :action => :update, :controller => :brew_entries, :id => entry.id, :render => "update_all_brewday" },
			BrewingUnits::values_array_for_display( current_user.units.volume, entry.mash_dead_space, 2 ), "Update Mash Lose"  )


	end

  def ajax_brewday_evapouration_rate_editor(entry)
#
#    ajax_edit_field( "evap_rate",
#			[number_with_precision(entry.evaporation_rate,2)],
#			"evaporation_rate",
#			url_for(  :controller => "brew_entries", :action => :update_evaporation_rate, :id => entry.id, :render => "update_all_brewday" ), "Update Evapouration Rate" )
#
            ajax_edit_field2( entry, "evaporation_rate",
			{ :action => :update, :controller => :brew_entries, :id => entry.id, :render => "update_all_brewday" },
			[decimal(entry.evaporation_rate)], "Update Evapouration Rate"  )

  end

  def ajax_brewday_boil_time_editor(entry)

#    ajax_edit_field( "boil_time",
#			[number_with_precision(entry.boil_time,2)],
#			"boil_time",
#			url_for(  :controller => "brew_entries", :action => :update_boil_time, :id => entry.id, :render => "update_all_brewday" ), "Update Boil Time" )

    ajax_edit_field2( entry, "boil_time",
			{ :action => :update, :controller => :brew_entries, :id => entry.id, :render => "update_all_brewday" },
			[decimal(entry.boil_time)], "Update Boil Time"  )
  end

  def ajax_brewday_boiler_lose_editor( entry )
#    ajax_edit_field( "mash_lose",
#			BrewingUnits::values_array_for_display( current_user.units.volume, entry.mash_dead_space, 2 ),
#			"mash_dead_space",
#			url_for(  :controller => "brew_entries", :action => :update_mash_lose, :id => entry.id, :render => "update_all_brewday" ), "Update Mash Lose" )
#

        ajax_edit_field2( entry, "boiler_loses",
			{ :action => :update, :controller => :brew_entries, :id => entry.id, :render => "update_all_brewday" },
			BrewingUnits::values_array_for_display( current_user.units.volume, entry.boiler_loses, 2 ), "Update Boiler Lose"  )


	end



  def ajax_brewday_mash_conversion_editor( entry )

    mc = 100.0
    mc = entry.mash_conversion if entry.mash_conversion

    ajax_edit_field( "conversion",
      [decimal(mc)],
			"conversion",
			url_for(  :controller => "brew_entries", :action => :update_conversion, :id => entry.id ), "Update Mash Conversion" )
	end


	def ajax_log_og_editor( entry )
		ajax_edit_field( "og",
			BrewingUnits::values_array_for_display( current_user.units.gravity, entry.actual_og, 3 ),
			"og",
			url_for(  :controller => "brew_entries", :action => :update_og, :id => entry.id ),
			"Update OG" )
	end

	def ajax_log_fg_editor( entry )
		ajax_edit_field( "fg",
			BrewingUnits::values_array_for_display( current_user.units.gravity, entry.fg, 3 ),
			"fg",
			url_for(  :controller => "brew_entries", :action => :update_fg, :id => entry.id ), "Update FG" )
	end

	def ajax_log_colour_editor( entry )
		colour =  "&nbsp;&nbsp;"
		colour = decimal(entry.actual_colour) if entry.actual_colour

		ajax_edit_field( "colour",
			[ colour ],
			"colour",
			url_for(  :controller => "brew_entries", :action => :update_colour, :id => entry.id ), "Update Colour" )
	end

	def brewlog_item_list(user)
		BrewEntry.find_all_by_user_id( user.id, :order => 'brew_date DESC' )
	end

  def ajax_brewday_wateraddition_editor( entry, field )
    ajax_edit_field2( entry, field,
                      { :action => :update_mashsparge,
                        :controller => :brew_entries,
                        :id => entry.id,
                        :render => "water" },
                      BrewingUnits::values_array_for_display( current_user.units.volume, entry.send(field), 2 ),
                      "Update #{field.to_s.titleize}" )
  end

  def ajax_brewday_dilution_editor( entry, field )
    ajax_edit_field2( entry, field,
                      { :action => :update_mashsparge,
                        :controller => :brew_entries, :id => entry.id,
                        :render => "water" },
                      [ entry.send(field) ],
                      "Update #{field.to_s.titleize}" )
  end

  def whatsbrewing_search_filter()
	   
    now = Date.current
	   
		filter = ""
		filter = session[:whatsbrewingSearchFilter] + " AND " if session[:whatsbrewingSearchFilter]
		filter = filter + "(brew_date <= '#{now.to_s(:db)}')" unless session[:whatsbrewingViewPlanned]

		logger.debug "Current search filter: #{filter}"

		return filter
  end


	
	def whatsbrewing_order_by
		return 'brew_date DESC' unless session[:whatsbrewingOrderBy]
		return session[:whatsbrewingOrderBy]
	end
	
	def whatsbrewing_brewlog_list
		logger.debug "page: #{params[:page]}"

    #BrewEntry.find(:all, :include => "recipe", :select => "*,recipes.name", :conditions => "recipes.name = 'Tripel'")
	
		return	  BrewEntry.paginate( :page => params[:page],
		  :per_page   => 20,
		  :conditions => whatsbrewing_search_filter(),
		  :order => whatsbrewing_order_by(),
		  :include => "recipe" )
	end
	
	def reset_whatsbrewing_filters
		session[:whatsbrewingSearchFilter] = nil
		session[:whatsbrewingOrderBy] = nil
		session[:whatsbrewingViewPlanned] = false
	end
	
	def brewlog_list
		now = Date.new()
		BrewEntry.find( :all, :order => 'brew_date DESC', :conditions => "brew_date <= #{now}" )
	end

	def log_obs_list( entry )
		entry.brew_entry_logs.find :all, :order => 'log_date DESC', :conditions => { :log_type => 'observation' }
  end

	def log_taste_list( entry )
		entry.brew_entry_logs.find :all, :order => 'log_date DESC', :conditions => { :log_type => 'tasting' }
  end

	def del_brewentry_link(log_entry)
		link_to( "Del", { :action => 'remove_brewentry_item', :id => log_entry.id }, :class => 'button small_button')
	end



	def users_breweries(user)
		Brewery.find_all_by_user_id(user.id, :order =>'name ASC')
	end


	def no_yeast_packets( cell_count, viability=0.94 )
		no_yeast_packets = (cell_count / 100e9)/viability
	end

	def dried_yeast_grams( cell_count )
		amount_dried_yeast = (cell_count / 20e9)/0.94
	end

	def yeast_slurry_final( cell_count, viability=0.94, trub=0.25 )
		# Assumes 25% trub per yeast solids per ml of slurry
		yeast_slurry = (cell_count/4.5e9)/(1.0-trub)/viability
	end

	def yeast_slurry_oneday( cell_count, viability=0.94, trub=0.25 )
		# Assumes 25% trub per yeast solids per ml of slurry
		yeast_slurry = (cell_count/2e9)/(1.0-trub)/viability
	end

	def yeast_slurry_onehour( cell_count, viability=0.94, trub=0.25 )
		# Assumes 25% trub per yeast solids per ml of slurry
		yeast_slurry = (cell_count/1e9)/(1.0-trub)/viability
	end

  def mash_step_addition_txt(mash_step)
    text = ""

    case mash_step.steptype

    when  "infusion"
      unit = volume_units()
      value = volume_values( mash_step.addition_amount )
      text = "#{value} [#{unit}]"
    when "decoction"
      unit = ferm_weight_units()
      value = ferm_weight_values( mash_step.addition_amount )
      text = "#{value} [#{unit}]"
    end

    return text
  end

  def recipe_fermentable_mash_list( recipe )

    thefermentables = recipe.fermentables.find(:all, :include => [:fermentable_type], 
      :conditions => "fermentable_types.mashed = 1", :order => "fermentable_types.name")
	end

  def recipe_fermentable_nonmash_list( recipe )

    thefermentables = recipe.fermentables.find(:all, :include => [:fermentable_type],
      :conditions => "fermentable_types.mashed = 0", :order => "fermentable_types.name")

	end


end
