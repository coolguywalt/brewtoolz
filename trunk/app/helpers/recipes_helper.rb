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

module RecipesHelper
	include UnitsHelper

	def add_fermentable_link(name)
		link_to_function name do |page|
			page.insert_html :bottom, :fermentables_list, :partial => 'fermentable' , :object => Fermentable.new
		end
	end

	# Updates the details partial and the fermentables partial
	def update_errors

		render(:update) { |page|
			if( recipe.brew_entry ) then
				page.replace_html 'details_div', :partial => 'shared/recipe_edit_summary', :object => recipe
			else
				page.replace_html 'details_div', :partial => 'details', :object => recipe
			end
			page.replace_html 'recipe_errors_div', :partial => 'shared/recipe_errors' }
	end


	def update_details_and_fermentables( recipe )
		# Need to update hops because the weight is dependent on the OG value.

		render(:update) { |page|

      update_common( recipe, page )

			page.replace_html 'fermentables_items_div', :partial => 'shared/recipe_edit_fermentables', :object => recipe
			page.replace_html 'hops_items_div', :partial => 'shared/recipe_edit_hops', :object => recipe

		}

	end

  def update_common( recipe, page )
    if( recipe.brew_entry ) then
      page.replace_html 'details_div', :partial => 'shared/recipe_edit_summary', :object => recipe
    else
      page.replace_html 'details_div', :partial => 'recipes/details', :object => recipe
      page.replace_html 'scale_div', :partial => 'shared/recipe_scale', :object => recipe
    end

    if( recipe.is_shared? ) then
      page.replace_html 'shared_user_status_div', :partial => 'shared/recipe_shared_users', :object => recipe
    end

    page.replace_html 'recipe_errors_div', :partial => 'shared/recipe_errors'
  end

  def update_details_and_fermentables_and_kits( recipe )
		# Need to update hops because the weight is dependent on the OG value.

		render(:update) { |page|

      update_common( recipe, page )

			page.replace_html 'fermentables_items_div', :partial => 'shared/recipe_edit_fermentables', :object => recipe
			page.replace_html 'hops_items_div', :partial => 'shared/recipe_edit_hops', :object => recipe
      page.replace_html 'kit_items_div', :partial => 'shared/recipe_edit_kits', :object => recipe
      page.replace_html 'kit_list_div', :partial => 'shared/recipe_edit_kits_list', :object => recipe
		}

	end

  def update_all( recipe )
		# Need to update hops because the weight is dependent on the OG value.

		render(:update) { |page|
      update_common( recipe, page )

			page.replace_html 'fermentables_items_div', :partial => 'shared/recipe_edit_fermentables', :object => recipe
			page.replace_html 'hops_items_div', :partial => 'shared/recipe_edit_hops', :object => recipe
      page.replace_html 'kit_items_div', :partial => 'shared/recipe_edit_kits', :object => recipe
      page.replace_html 'mashprofile_items_div', :partial => 'shared/recipe_edit_mashprofile', :object => recipe
      page.replace_html 'misc_items_div', :partial => 'shared/recipe_edit_misc', :object => recipe
      page.replace_html 'yeast_items_div', :partial => 'shared/recipe_edit_yeasts', :object => recipe
      page.replace_html 'lock_all_div', :partial => 'shared/recipe_lock_all', :object => recipe
      page.replace_html 'log_list_div', :partial => 'log', :object => recipe
		}

	end

  def update_shared_log( recipe )
		# Need to update hops because the weight is dependent on the OG value.

		render(:update) { |page|
       page.replace_html 'log_list_div', :partial => 'log', :object => recipe
		}

	end


  def update_details_and_kits( recipe )
		# Need to update hops because the weight is dependent on the OG value.

		render(:update) { |page|
      update_common( recipe, page )

			page.replace_html 'kit_items_div', :partial => 'shared/recipe_edit_kits', :object => recipe
 
		}

	end





	def update_details_and_fermentable( fermentable )
		# Need to update hops because the weight is dependent on the OG value.

		render(:update) { |page|

			#Update weight values
			values_str = BrewingUnits::values_for_display( current_user.units.fermentable,fermentable.weight , 2 )
			value_str = BrewingUnits::value_for_display( current_user.units.fermentable,fermentable.weight , 2 )
			id_prefix = "fw_#{fermentable.id}"

			page["#{id_prefix}_s"].update( values_str  )
			page["#{id_prefix}_e"].value = value_str

			#Update points values
			values_str = BrewingUnits::values_for_display( current_user.units.gravity,fermentable.points , 3 )
			value_str = BrewingUnits::value_for_display( current_user.units.gravity,fermentable.points , 3 )
			id_prefix = "fp_#{fermentable.id}"

			page["#{id_prefix}_s"].update( values_str  )
			page["#{id_prefix}_e"].value = value_str

			#Recipe details
			@recipe = fermentable.recipe

			#Original gravity
			page['og_s'].update(BrewingUnits::values_for_display( current_user.units.gravity,@recipe.og , 3 ) )
			# page['og_e'].value = (BrewingUnits::value_for_display( current_user.units.gravity,@recipe.og , 3 ) )

      page['abv'].update(@recipe.abv)
			page['atten'].update(percentage(@recipe.attenuation*100))
			page['colour'].update(decimal( @recipe.srm).to_s + " (" + decimal( @recipe.ebc).to_s + ")")
			page['bugu'].update(decimal( @recipe.bugu, 3 ))
			page['rte'].update(decimal( @recipe.rte))
			page['bal'].update(decimal( @recipe.balance, 3 ))
      page['ibu_tot'].update(decimal( @recipe.ibu))

			#Update percentage fermentable values
			fermentable.recipe.fermentables.each do |ferm|
				page["fp_per_#{ferm.id}"].update( percentage(ferm.percentage_points * 100) )
				page["fw_per_#{ferm.id}"].update(percentage(ferm.percentage_weight * 100))
			end

			#Update percentage hop weight values
			fermentable.recipe.hops.each do |hop|
				values_str = BrewingUnits::values_for_display( current_user.units.hops, hop.weight , 2 )
				value_str = BrewingUnits::value_for_display( current_user.units.hops, hop.weight , 2 )
				id_prefix = "hw_#{hop.id}"

				page["#{id_prefix}_s"].update( values_str  )
				page["#{id_prefix}_e"].value = value_str
			end

     	#Update associated partials
			# page.replace_html 'hops_div', :partial => 'shared/recipe_edit_hops', :object => fermentable.recipe
			page.replace_html 'recipe_errors_div', :partial => 'shared/recipe_errors'
		}

	end


  # Updates the details partial and the fermentables partial
	def update_details_and_hops( recipe )
		render(:update) { |page|
  
      update_common( recipe, page )

			page.replace_html 'hops_items_div', :partial => 'shared/recipe_edit_hops', :object => recipe
    }
  end

  def update_details_and_hop( hop )

    render(:update) { |page|

      #Update per weight values
      values_str = BrewingUnits::values_for_display( current_user.units.hops, hop.weight , 2 )
      value_str = BrewingUnits::value_for_display( current_user.units.hops, hop.weight , 2 )
      id_prefix = "hw_#{hop.id}"

      page["#{id_prefix}_s"].update( values_str  )
      page["#{id_prefix}_e"].value = value_str

      #Update per ibu values
      value_str = decimal(hop.ibu_l)
      id_prefix = "ibu_#{hop.id}"

      page["#{id_prefix}_s"].update( value_str  )
      page["#{id_prefix}_e"].value = value_str

      #Update per aa values
      value_str = decimal(hop.aa)
      id_prefix = "aa_#{hop.id}"

      page["#{id_prefix}_s"].update( value_str  )
      page["#{id_prefix}_e"].value = value_str

      #Update per minutes values
      value_str = hop_minutes_format(hop)
      id_prefix = "minutes_#{hop.id}"

      page["#{id_prefix}_s"].update( value_str  )
      page["#{id_prefix}_e"].value = value_str


      #Update points values
      #			values_str = BrewingUnits::values_for_display( current_user.units.gravity,fermentable.points , 3 )
      #			value_str = BrewingUnits::value_for_display( current_user.units.gravity,fermentable.points , 3 )
      #			id_prefix = "fp_#{fermentable.id}"

      #			page["#{id_prefix}_s"].update( values_str  )
      #			page["#{id_prefix}_e"].update( value_str  )

      #Recipe details
      @recipe = hop.recipe

      #Original gravity
      #			page['og_s'].update(BrewingUnits::values_for_display( current_user.units.gravity,@recipe.og , 3 ) )
      #			page['og_e'].update(BrewingUnits::value_for_display( current_user.units.gravity,@recipe.og , 3 ) )

      #     page['abv'].update(@recipe.abv)
      #		page['atten'].update(percentage(@recipe.attenuation*100))
      #		page['colour'].update(decimal( @recipe.srm, 2 ).to_s + " (" + decimal( @recipe.ebc, 2 ).to_s + ")")
      page['bugu'].update(decimal( @recipe.bugu, 3 ))
      #		page['rte'].update(decimal( @recipe.rte, 2 ))
      page['bal'].update(decimal( @recipe.balance, 3 ))

      page['ibu_tot'].update(decimal( @recipe.ibu ))

      #Update percentage fermentable values
      #			fermentable.recipe.fermentables.each do |ferm|
      #				page["fp_per_#{ferm.id}"].update( percentage(ferm.percentage_points * 100) )
      #				page["fw_per_#{ferm.id}"].update(percentage(ferm.percentage_weight * 100))
      #			end

      #Update percentage hop weight values
      hop.recipe.hops.each do |ahop|
        value_str = percentage( ahop.percentage_ibu()*100 )
        #value_str = ( current_user.units.hop, ahop.weight , 2 )
        id_prefix = "hpw_#{ahop.id}"

        page["#{id_prefix}"].update( value_str  )
        #page["#{id_prefix}_e"].update( value_str  )
      end

      #Update associated partials
      # page.replace_html 'hops_items_div', :partial => 'shared/recipe_edit_hops', :object => fermentable.recipe
      page.replace_html 'recipe_errors_div', :partial => 'shared/recipe_errors'
    }

  end

  # Updates the details partial and the fermentables partial
  def render_mashsteps( recipe )
    render(:update) { |page|
      update_common( recipe, page )
      page.replace_html 'mashprofile_items_div', :partial => 'shared/recipe_edit_mashprofile', :object => recipe
    }
  end

  def render_misc( recipe )
    render(:update) { |page|
      update_common( recipe, page )
      page.replace_html 'misc_items_div', :partial => 'shared/recipe_edit_misc', :object => recipe
    }
  end

  def update_just_hops( recipe )
    render(:update) { |page|
      page.replace_html 'hops_items_div', :partial => 'shared/recipe_edit_hops', :object => recipe
      page.replace_html 'recipe_errors_div', :partial => 'shared/recipe_errors' }
  end

  def update_recipe_main
    render(:update) { |page|
      page.replace_html 'recipe_type_details', :partial => 'type_details'
      page.replace_html 'errors', :partial => 'errors' }
  end


  def update_details_and_yeast( recipe )
    render(:update) { |page|
      update_common( recipe, page )
      page.replace_html 'yeast_items_div', :partial => 'shared/recipe_edit_yeasts', :object => recipe
    }
  end

  def update_shared_users( recipe, error_list=nil )

    render(:update) { |page|
      if( error_list ) then
        page.replace_html 'add_name_results', simple_format(error_list)
      end
      page.replace_html 'shared_user_status_div', :partial => 'shared/recipe_shared_users', :object => recipe
    }

  end

  def ajax_volume_editor( recipe )

    ajax_edit_field2( recipe, "volume",
      { :action => :update, :controller => :recipes, :id => recipe.id, :render => "details_and_fermentables_and_kits" },
      BrewingUnits::values_array_for_display( current_user.units.volume, recipe.volume, 2 ) )
  end

  def ajax_eff_editor( recipe )
    eff = recipe.efficency || eff = 75.0

    ajax_edit_field2( recipe, "efficency",
      {  :action => :update, :controller => :recipes, :id => recipe.id, :render => "details_and_fermentables" } )
		
    #		ajax_edit_field( "efficency",
    #			[ decimal(recipe.efficency,2) ],
    #			"efficency",
    #			url_for(  :controller => "recipes", :action => :update_eff, :id => recipe.id ),
    #			" Update Efficency" )
  end

  def ajax_og_editor

    ajax_edit_field2( @recipe, "og",
      { :action => :update, :controller => :recipes, :id => @recipe.id, :render => "details_and_fermentables" },
      BrewingUnits::values_array_for_display( current_user.units.gravity,@recipe.og , 3 ) )

    #		ajax_edit_field( "og",
    #			BrewingUnits::values_array_for_display( current_user.units.gravity,@recipe.og , 3 ),
    #			"og",
    #			url_for(  :controller => "recipes", :action => :update_og, :id => @recipe.id ), "Update OG" )
  end

  #  def ajax_simple_og_editor( recipe )
  #		ajax_edit_field( "simple_og",
  #			BrewingUnits::values_array_for_display( current_user.units.gravity, recipe.simple_og, 3 ),
  #			"simple_og",
  #			url_for( :action => :update_simple_og, :id => recipe.id ), "Update OG" )
  #	end
  #
  #	def ajax_simple_fg_editor( recipe )
  #		ajax_edit_field( "simple_fg",
  #			BrewingUnits::values_array_for_display( current_user.units.gravity,recipe.simple_fg , 3 ),
  #			"simple_fg",
  #			url_for( :action => :update_simple_fg, :id => recipe.id ), "Update FG" )
  #	end
  #
  #	def ajax_simple_ibu_editor( recipe )
  #		ajax_edit_field( "simple_ibu",
  #			[ (recipe.simple_ibu ? decimal(recipe.simple_ibu,2) : "invalid") ],
  #			"simple_ibu",
  #			url_for( :action => :update_simple_ibu, :id => recipe.id ), "Update IBU" )
  #	end
  #
  #  def ajax_simple_srm_editor( recipe )
  #		ajax_edit_field( "simple_srm",
  #			[ (recipe.simple_srm ? decimal(recipe.simple_srm,2) : "invalid") ],
  #			"simple_srm",
  #			url_for( :action => :update_simple_srm, :id => recipe.id ), "Update SRM" )
  #	end


  def recipe_fermentable_list( recipe )
    recipe.fermentables.sort { |a,b|
      # following two lines deal with null values.
      next -1 unless a && a.fermentable_type && a.fermentable_type.name
      next 1 unless b && b.fermentable_type && b.fermentable_type.name

      a.fermentable_type.name <=> b.fermentable_type.name
    }
  end

 


  def recipe_hops_list ( recipe )
    recipe.hops.sort do |a,b|
      if a.minutes == b.minutes then
        a.hop_type.name <=> b.hop_type.name
      else
        # reserve comparison to make it decending
        (a.minutes <=> b.minutes) * -1

      end
    end
  end

  def recipe_kits_list ( recipe )
    recipe.kits.sort do |a,b|
      a.kit_type.name <=> b.kit_type.name
    end
  end

  def recipe_yeast_list ( recipe )
    recipe.yeasts.sort do |a,b|
      a.yeast_type.name <=> b.yeast_type.name
    end
  end

  def fermentable_type( fermentable )
    fermentable.fermentable_type || '(Undefined type)'
  end

  def hop_type( hop )
    hop.hop_type || '(Undefined type)'
  end

  def kit_type( kit )
    kit.kit_type || '(Undefined type)'
  end

  def kit_volume( kit )
    return "n/a" unless kit.volume
    return volume_values( kit.volume )
  end

  def kit_designed_volume( kit )
    return "n/a" unless kit.designed_volume
    return volume_values( kit.designed_volume )
  end

  def kit_weight( kit )
    return "n/a" unless kit.weight
    return ferm_weight_values(kit.weight)
  end

  def kit_ibus( kit, volume )
    return decimal(ferm_weight_values(kit.kit_ibus(volume)))
  end

  def kit_points( kit, volume )
    return gravity_values( kit.kit_points(volume))
  end

  def yeast_type( yeast )
    yeast.yeast_type || '(Undefined type)'
  end


  def ajax_points_editor( fermentable )
    #object, field_name, url_for_edit=nil, values_arr=nil, spinner_message=nil, tag_field=nil, id_prefix=nil
    ajax_edit_field2( fermentable, "points",
      { :action => :update, :controller => :fermentables, :id => fermentable.id, :render => "details_and_fermentable" },
      BrewingUnits::values_array_for_display( current_user.units.gravity,fermentable.points , 3 ),
      nil, nil, "fp_#{fermentable.id}")
    #
    #		ajax_edit_field_group( "points_#{fermentable.id}",
    #			BrewingUnits::values_array_for_display( current_user.units.gravity, fermentable.points, 3),
    #			"points",
    #			url_for( :controller => "recipes", :action => :update_fermentable_points ,
    #				:id => fermentable.recipe.id,
    #				:fermentable_id => fermentable.id ), "Update Fermentable Gravity", ["weight_#{fermentable.id}" ]
    #		)
  end

  def ajax_weight_editor( fermentable )

    ajax_edit_field2( fermentable, "weight",
      { :action => :update, :controller => :fermentables, :id => fermentable.id, :render => "details_and_fermentable" },
      BrewingUnits::values_array_for_display( current_user.units.fermentable, fermentable.weight, 2 ),
      nil, nil, "fw_#{fermentable.id}")

    #		ajax_edit_field_group( "weight_#{fermentable.id}",
    #			BrewingUnits::values_array_for_display( current_user.units.fermentable, fermentable.weight, 2),
    #			"weight",
    #			url_for(  :controller => "recipes",:action => :update_fermentable_weight ,
    #				:id => fermentable.recipe.id,
    #				:fermentable_id => fermentable.id ), "Update Fermentable Weight", ["points_#{fermentable.id}" ] )
  end

  def ajax_per_weight_editor( fermentable )
    ajax_edit_field_group( "per_weight_#{fermentable.id}",
      [ decimal(fermentable.percentage_weight*100) ],
      "per_weight",
      url_for(  :controller => "recipes", :action => :update_fermentable_per_weight ,
        :id => fermentable.recipe.id,
        :fermentable_id => fermentable.id ), "Update Fermentable % Weight", ["points_#{fermentable.id}","weight_#{fermentable.id}" ] )
  end

  def del_fermentable_link(fermentable)
    link_to_remote( "Delete",
      :loading => "Hobo.showSpinner('Delete Fermentable');",
      :complete => "Hobo.hideSpinner();",
      :url => { :controller => "recipes", :action => "remove_fermentable", :id => fermentable.recipe.id, :comment => fermentable.id  },
      :html => { :class => 'button small-button' }  )
  end

  def ajax_aa_editor( hop )
    #		ajax_edit_field_group( "aa_#{hop.id}",
    #			[ decimal(hop.aa,2) ],
    #			"aa",
    #			url_for(  :controller => "recipes", :action => :update_hop_aa ,
    #				:id => hop.recipe.id,
    #				:hop_id => hop.id ), "Update AA%", ["ibu_#{hop.id}","weight_#{hop.id}","minutes_#{hop.id}"] )
    #
    #
    ajax_edit_field2( hop, "aa",
      { :action => :update, :controller => :hops, :id => hop.id, :render => "details_and_hop" },
      [ decimal(hop.aa) ],
      nil, nil, "aa_#{hop.id}")
  end

  def ajax_ibu_editor( hop )
    #		ajax_edit_field_group( "ibu_#{hop.id}",
    #			[ decimal(hop.ibu_l,2) ],
    #			"ibu",
    #			url_for( :controller => "recipes", :action => :update_hop_ibu ,
    #				:id => hop.recipe.id,
    #				:hop_id => hop.id ), "Update IBU",  ["aa_#{hop.id}","weight_#{hop.id}","minutes_#{hop.id}"] )


    ajax_edit_field2( hop, "ibu_l",
      { :action => :update, :controller => :hops, :id => hop.id, :render => "details_and_hop" },
      [ decimal(hop.ibu_l) ],
      "Updating IBU", nil, "ibu_#{hop.id}")


  end

  def ajax_hop_weight_editor( hop )
    #		ajax_edit_field_group( "weight_#{hop.id}",
    #			BrewingUnits::values_array_for_display( current_user.units.hops, hop.weight, 2 ),
    #			"weight",
    #			url_for(  :controller => "recipes", :action => :update_hop_weight,
    #				:id => hop.recipe.id,
    #				:hop_id => hop.id ), "Update Hop Weight",  ["aa_#{hop.id}","ibu_#{hop.id}","minutes_#{hop.id}"])
    ajax_edit_field2( hop, "weight",
      { :action => :update, :controller => :hops, :id => hop.id, :render => "details_and_hop" },
      BrewingUnits::values_array_for_display( current_user.units.hops, hop.weight, 2 ),
      nil, nil, "hw_#{hop.id}")

  end

  def ajax_minutes_editor( hop )
    #		ajax_edit_field_group( "minutes_#{hop.id}",
    #			[minutes_format( hop.minutes )],
    #			"minutes",
    #			url_for(  :controller => "recipes", :action => :update_hop_minutes,
    #				:id => hop.recipe.id,
    #				:hop_id => hop.id ), "Update Hop Minutes", ["aa_#{hop.id}","ibu_#{hop.id}","weight_#{hop.id}"] )

    ajax_edit_field2( hop, "minutes",
      { :action => :update, :controller => :hops, :id => hop.id, :render => "details_and_hop" },
      [hop_minutes_format(hop)],
      nil, nil, "minutes_#{hop.id}")

  end

  def ajax_quantity_editor( kit )
    ajax_edit_field2( kit, "quantity",
      { :action => :update, :controller => :kits, :id => kit.id, :render => "details_and_kit" },
      [ decimal(kit.quantity)],
      nil, nil, "quantity_#{kit.id}")
  end


  def ajax_lock_edit( item, field_name, controller, action, render, is_disabled=false, show_ajax_indicator=false )

    action_url = url_for(:controller => controller, :action => action, :id => item.id, :render => render)

    render( :inline => %{
    <% form_remote_for( item,
          :url => action_url, :html => {:id => "lock_#{item.id}"}  #{show_ajax_indicator ? ', :loading => "Hobo.showSpinner(\"Processing ...\");", :complete => "Hobo.hideSpinner();"': ''}  ) do |f|%>
          <%= f.check_box field_name, :onclick => "$('lock_#{item.id}').onsubmit();" #{is_disabled ? ', :disabled => "disabled"' : ''}  %>
    <% end %>
      }, :locals => {:action_url => action_url, :item => item, :field_name => field_name } )
   
  end

  def scale_recipe(recipe)
  
    render( :inline => %{
   <% form_remote_tag(
           :url => {  :controller => "recipes", :action => :scale_recipe, :id => recipe.id, :new_volume => new_volume, :new_eff => eff  },
           :html => {:id => "scale_recipe_#{recipe.id}"},
			     :loading => "Hobo.showSpinner('Scaling Recipe');",
			     :complete => "Hobo.hideSpinner();",
        ) do |f|%>
           <label>New Volume [<%= volume_unit(current_user) %>]: </label><input type="text" name="new_volume" size="4" /><br/>
           <label>New Efficiency [%]: </label><input type="text" name="new_eff" size="4" /><br/>
           <submit value="Ok" class="button small-button"/>
      <% end %>
      } )
  
  end


  def del_hop_link(hop)
    link_to_remote( "Delete",
      :loading => "Hobo.showSpinner('Delete Hops');",
      :complete => "Hobo.hideSpinner();",
      :url => {  :controller => "recipes", :action => :remove_hop, :id => hop.recipe.id, :hop_id => hop.id  },
      :html => { :class => 'button small-button' }     )
  end

  def del_kit_link(kit)
    link_to_remote( "Delete",
      :loading => "Hobo.showSpinner('Delete Kit');",
      :complete => "Hobo.hideSpinner();",
      :url => {  :controller => "recipes", :action => :remove_kit, :id => kit.recipe.id, :kit_id => kit.id  },
      :html => { :class => 'button small-button' }     )
  end

  def del_shared_user_link(recipe, shared_user)

    if( recipe.user == current_user ) then
      return link_to_remote( "Del", :loading => "Hobo.showSpinner('Delete Shared User');", :complete => "Hobo.hideSpinner();", :url => {  :controller => "recipes", :action => :remove_shared_user, :id => recipe.id, :shared_user_id => shared_user.id  }, :html => { :class => 'button small-button' }  )
    else
      return link_to( "Del", {:controller => "recipes", :action => :remove_shared_user, :id => recipe.id, :shared_user_id => shared_user.id }, :class => 'button small-button' )
    end
  end

    def add_shared_msg_link(recipe)
    link_to_remote( "Add Shared Log Message",
      :loading => "Hobo.showSpinner('Adding Message');",
      :complete => "Hobo.hideSpinner();",
      :url => {  :controller => "recipes", :action => :add_shared_log_message, :id => recipe.id, :message => ""  },
      :html => { :class => 'button small-button' }     )
  end

  def del_yeast_link(yeast)
    link_to_remote( "Delete",
      :loading => "Hobo.showSpinner('Delete Yeast');",
      :complete => "Hobo.hideSpinner();",
      :url => {  :controller => "recipes", :action => "remove_yeast", :id => yeast.recipe.id, :yeast_id => yeast.id  },
      :html => { :class => 'button small-button' }   )
  end

  def del_mashstep_link(mashstep)
    link_to_remote( "Delete",
      :loading => "Hobo.showSpinner('Delete Mash Entry');",
      :complete => "Hobo.hideSpinner();",
      :url => {  :controller => "recipes", :action => "remove_mashstep", :id => mashstep.recipe.id, :mashstep_id => mashstep.id  },
      :html => { :class => 'button small-button' }   )
  end

  def del_misc_link(misc)
    link_to_remote( "Delete",
      :loading => "Hobo.showSpinner('Delete Misc Entry');",
      :complete => "Hobo.hideSpinner();",
      :url => {  :controller => "recipes", :action => "remove_misc", :id => misc.recipe.id, :misc_id => misc.id  },
      :html => { :class => 'button small-button' }   )
  end

  def recipe_brewlog_list( recipe )
    recipe.brew_entries.sort do |a,b|
      a.brew_date <=> b.brew_date
    end
  end


  def index_recipe_list
    logger.debug "index recipe list"


    return Recipe.find(:all, :order => 'created_at DESC, name', :conditions => $PRIMARY_RECIPE_FILTER )
  end

  def can_clone?
    !current_user.guest?
  end

  def recipe_mashprofile_list(recipe)
    return MashStep.find_all_by_recipe_id(recipe.id, :order => 'temperature, name')
  end

  def recipe_misc_list(recipe)
    return MiscIngredient.find_all_by_recipe_id(recipe.id, :order => 'misc_type, time, name')
  end

  def styles_for_category(category)
    Style.find(:all, :order => :designator, :conditions => "category_id = #{category.id}")
  end

  def ordered_category_list()
    Category.find(:all, :order => "CAST(designator AS UNSIGNED)")
  end

  def index_search_filter()
    filter = ""
    filter = session[:recipeSearchFilter] + " AND " if session[:recipeSearchFilter]
    filter = filter +  "(style_id in (#{session[:recipeStyleSelection].join(',')}))"  + " AND " if session[:recipeStyleSelection]
    filter = filter + "(" + $PRIMARY_RECIPE_FILTER + ")"

    logger.debug "Current search filter: #{filter}"

    return filter
  end

  def reset_search_filters
    session[:recipeSearchFilter] = nil
    session[:recipeStyleSelection] = nil
    session[:recipeOrderBy] = nil
  end

  def index_search_filter_exclude_styles()
    filter = ""
    filter = session[:recipeSearchFilter] + " AND " if session[:recipeSearchFilter]
    filter = filter + "(" + $PRIMARY_RECIPE_FILTER + ")"

    logger.debug "Current search filter: #{filter}"

    return filter
  end


  def category_recipe_count( category )
    cat_count = 0
    category.styles.each { |style|
      cat_count += style.recipes.count( index_search_filter() )
    }
		
    return cat_count
  end
	
  def index_order_by
    return 'name' unless session[:recipeOrderBy]
    return session[:recipeOrderBy]
  end
	
  def index_recipes_list
    logger.debug "page: #{params[:page]}"

    return	  Recipe.paginate( :page => params[:page],
      :per_page   => 20,
      :conditions => index_search_filter(),
      :order => index_order_by() )
  end

  def process_category_and_styles( category )
    cat_count = 0
    cat_selected = false

    styles_array = session[:recipeStyleSelection]
    style_data = []

    a = [1,2,3,4]
    a.index(2)

    category.styles.each { |style|
      style_count = style.recipes.count( index_search_filter_exclude_styles() )
      style_selected = nil
      style_selected = styles_array.index( style.id.to_s ) if styles_array
			
      style_class = "recipe_none" unless style_count > 0
      style_class = "recipe_selected" if style_selected

      style_data << {:count => style_count, :selected => (style_selected != nil),
        :text => "#{style.designator}.#{style.name}", :class => style_class, :id => style.id }

      cat_count += style_count
      cat_selected = cat_selected || (style_selected != nil)
    }

    cat_class = "recipe_none" unless cat_count > 0
    cat_class = "recipe_selected" if cat_selected


    cat_data = { :count => cat_count, :selected => cat_selected, :class => cat_class }

    return cat_data, style_data
  end


  def update_search_results( recipes )

    styles_array = session[:recipeStyleSelection]
    cats = ordered_category_list()

    render :update do |page|
      page.replace_html 'recipe_collecion_div', :partial => 'shared/recipe_collection', :object => recipes

      cats.each {|cat|

        cat_count = 0
        cat_selected = false


        cat.styles.each { |style|

          style_count = style.recipes.count( 'id', :conditions => index_search_filter_exclude_styles() )
          style_selected = nil
          style_selected = styles_array.index( style.id.to_s ) if styles_array

          style_class = "recipe_none" unless style_count > 0
          style_class = "recipe_selected" if style_selected


          cat_count += style_count
          cat_selected = cat_selected || (style_selected != nil)

          #format and updated the required page items for the style
          page["sco#{style.id}"].update(style_count)
          page << "$('scl#{style.id}').className =  '#{style_class}'"
				

        }

        cat_class = "recipe_none" unless cat_count > 0
        cat_class = "recipe_selected" if cat_selected

        #format and updated the required page items for the category
        page["cco1#{cat.id}"].update(cat_count)
        page["cco2#{cat.id}"].update(cat_count)

        page << "$('ccl1#{cat.id}').className =  '#{cat_class}'"
        page << "$('ccl2#{cat.id}').className =  '#{cat_class}'"
      }
    end
  end

  def update_search_results_selection( recipes )

    styles_array = session[:recipeStyleSelection]
    cats = ordered_category_list()

    render :update do |page|
      page.replace_html 'recipe_collecion_div', :partial => 'shared/recipe_collection', :object => recipes

      cats.each {|cat|

        #cat_count = 0
        cat_selected = false


        cat.styles.each { |style|

          #style_count = style.recipes.count( index_search_filter() )
          style_selected = nil
          style_selected = styles_array.index( style.id.to_s ) if styles_array

          #style_class = "recipe_none" unless style_count > 0
          #style_class = "recipe_selected" if style_selected


          #cat_count += style_count
          cat_selected = cat_selected || (style_selected != nil)

          #format and updated the required page items for the style
          #page["sco#{style.id}"].update(style_count)
          #page << "$('scl#{style.id}').className =  '#{style_class}'"
          page << "$('scl#{style.id}').classNames().add('recipe_selected')" if style_selected
          page << "$('scl#{style.id}').classNames().remove('recipe_selected')" unless style_selected

        }

        #cat_class = "recipe_none" unless cat_count > 0
        #cat_class = "recipe_selected" if cat_selected

        #format and updated the required page items for the category
        #page["cco1#{cat.id}"].update(cat_count)
        #page["cco2#{cat.id}"].update(cat_count)

        page << "$('ccl1#{cat.id}').classNames().add('recipe_selected')" if cat_selected
        page << "$('ccl1#{cat.id}').classNames().remove('recipe_selected')" unless cat_selected
        page << "$('ccl2#{cat.id}').classNames().add('recipe_selected')" if cat_selected
        page << "$('ccl2#{cat.id}').classNames().remove('recipe_selected')" unless cat_selected

      }
    end
  end

  def show_shared?( recipe )
    logger.debug "++show_shared? recipe: #{recipe}"
    logger.debug "++show_shared? is_brewday? #{recipe.is_brewday?}"
    logger.debug "++show_shared? is_owner?: #{recipe.is_owner?}"

    return (!recipe.is_brewday? and recipe.is_owner?)
  end

end
