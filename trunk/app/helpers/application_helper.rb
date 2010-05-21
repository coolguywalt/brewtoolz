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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  $PRIMARY_RECIPE_FILTER = "(brew_entry_id IS NULL) AND (name IS NOT NULL) AND (name <> \"\")"

	def stored_location
		session[:return_to] || "/"
  end

	# We can return to this location by calling #redirect_back_or_default.
  def store_location( uri = nil )

		logger.debug "uri: #{uri}, request_uri: #{request.request_uri}"

		uri = request.request_uri unless uri
		session[:return_to] = request.request_uri
  end

	def link_away(name, options = {}, html_options = nil)
		link_to(name, { :return_uri => url_for(:only_path => true) }.update(options.symbolize_keys), html_options)
  end

	def hop_minutes_format( hop )
		return "Dry Hopped" if hop.hop_use == :dry_hop
  	return "Hop Tea" if hop.hop_use == :hop_tea
		return  decimal(hop.minutes)
	end

	def ajax_edit_field( id_prefix, values, tag_field, url_for_edit, spinner_message )
		logger.debug( "values: #{values}")

		value1 = values[0]
		value2 = values.length > 1 ? values[1] : nil
		render :partial => "shared/ajax_editor",
		  :locals => { :value => value1, :id_prefix => id_prefix, :alt_value => value2,
			:tag_field =>tag_field, :url_for_edit => url_for_edit, :message => spinner_message
		}
	end

	def ajax_edit_field2( object, field_name, url_for_edit=nil, values_arr=nil, spinner_message=nil, tag_field=nil, id_prefix=nil )
		logger.debug( "values ajax_edit_field2: #{values_arr}")
		 
		id_prefix = field_name unless id_prefix
		tag_field = field_name unless tag_field
		spinner_message = "Updating #{field_name}" unless spinner_message
    url_for_edit = { :action => :update, :id => object.id } unless url_for_edit

		value1=""
		display_value_str = ""

		if values_arr then
			value1 = values_arr[0]
			display_value_str = "#{value1}" + (values_arr.length > 1 ? "(#{values_arr[1]})":"")
		else
			value1 = object.[](field_name).to_s
			display_value_str = value1
		end

		render :partial => "shared/ajax_editor2",
		  :locals => { :value_str => value1, :value_display_str => display_value_str, :id_prefix => id_prefix,
			:tag_field =>tag_field, :url_for_edit => url_for_edit, :message => spinner_message,
			:object => object, :field_name => field_name
		}
		
	end


	def ajax_edit_field_group(id_prefix, values, tag_field, url_for_edit, spinner_message, group)
		value1 = values[0]
		value2 = values.length > 1 ? values[1] : nil
		render :partial => "shared/ajax_editor_group",
		  :locals => { :value => value1, :id_prefix => id_prefix, :alt_value => value2,
			:tag_field =>tag_field, :url_for_edit => url_for_edit, :message => spinner_message, :group => group
		}
	end


	def primary_recipes()
		logger.debug "primary_recipes called"
		# Find parent recipes that do not belong to brew_entries
		#@recipes = Recipe.find(:all, :conditions => "brew_entry_id IS NULL", :order => 'name')
		return Recipe.paginate(:per_page =>30, :order =>'name', :conditions => $PRIMARY_RECIPE_FILTER, :page => params[:page] )

		#return @recipes
	end

	def top_rated_recipes()
		Recipe.find(:all, :order => 'rating DESC', :limit => 7,  :conditions => $PRIMARY_RECIPE_FILTER)
	end

	def recent_recipes()
		Recipe.find(:all, :order => 'created_at DESC', :limit => 5,  :conditions => $PRIMARY_RECIPE_FILTER + " AND (draft IS NULL OR draft <> 1)")
  end

	def last_15_members_recipes(user)
		Recipe.find_all_by_user_id(user.id, :order => 'created_at ASC', :limit => 15,  :conditions => $PRIMARY_RECIPE_FILTER)
	end

	def brewers_shared_recipes(user)
    list = RecipeUserShared.find_all_by_user_id( user.id )

    return list.sort { |a,b|
      a.recipe_shared.recipe.name <=> b.recipe_shared.recipe.name
    }

	end


  def brewers_recipes(user)
		Recipe.find_all_by_user_id(user.id, :order => 'name', :conditions => $PRIMARY_RECIPE_FILTER)
	end

	def brewers_logs(user)
		BrewEntry.find_all_by_user_id(user.id, :order => 'brew_date DESC')
	end


	def view_rating( therating )
		return "n/a" if therating < 0.0
		return decimal(therating)
	end

	def element_groups( group )
		return "" unless group

		element_str = ""
		group.each do |id|
			element_str = element_str + "Element.hide('" + id + "_edit');Element.show('" + id + "_show');"
		end
		return element_str

	end


	def delayed_observe_field(field_id, options = {})
		custom_build_observer('Form.Element.DelayedObserver', field_id, options)
	end


	def delayed_observe_form(form_id, options = {})
		custom_build_observer('Form.DelayedObserver', form_id, options)
	end




	# Ripped directly from the Rails Protype library cause we dont know how to do it properly
	def custom_build_observer(klass, name, options = {})
		if options[:with] && (options[:with] !~ /[\{=(.]/)
			options[:with] = "'#{options[:with]}=' + encodeURIComponent(value)"
		else
			options[:with] ||= 'value' unless options[:function]
		end

		callback = options[:function] || remote_function(options)
		javascript  = "new #{klass}('#{name}', "
		javascript << "#{options[:frequency]}, " if options[:frequency]
		javascript << "function(element, value) {"
		javascript << "#{callback}}"
		javascript << ")"
		javascript_tag(javascript)
	end

  # Copied here as it is used in may different views
  def brew_day_link(log_entry)
		link_to( "Brewday", { :controller => :brew_entries, :action => 'brewday', :id => log_entry.id }, :class => 'button small_button')
	end

  def brew_recipe_link(log_entry)
		link_to( "Recipe", { :controller => :brew_entries, :action => 'brewdayrecipe', :id => log_entry.id }, :class => 'button small_button')
	end
  def brew_log_link(log_entry)
		link_to( "Brewlog", { :controller => :brew_entries, :action => 'show', :id => log_entry.id }, :class => 'button small_button')
	end
	def del_brewlogitem_link(brewlog_item)
		link_to( "Del", { :controller => :brew_entries, :action => 'remove_brewlog_item', :id => brewlog_item.id }, :class => 'small-button')
	end

  def del_recipe_link_nf(recipe)
		link_to( "Del", { :controller => :recipes, :action => 'del_recipe', :id => recipe.id } ) #, :class => 'button small_button')
	end

  def del_recipe_link(recipe)
		link_to( "Del", { :controller => :recipes, :action => 'del_recipe', :id => recipe.id , :class => 'button small_button'} )
	end

  def style_recipes( style )
		style.recipes.paginate(:all, :per_page =>30, :order => 'name', :conditions => 'brew_entry_id IS NULL', :page => params[:page])
	end

  def decimal( value, places=2 )
    number_with_precision( value, :precision => places )
  end

  def percentage( value )
    number_to_percentage(value, :precision => 2)
  end

  def strwrap(s, width=80)
    s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
  end

end
