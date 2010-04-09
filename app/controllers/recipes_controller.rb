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

class RecipesController < ApplicationController

	hobo_model_controller
	include RecipesHelper
	include ApplicationHelper
  include AppSecurity

	auto_actions :all

	def print
		@recipe = Recipe.find(params[:id])
	end


  def print_text
		@recipe = Recipe.find(params[:id])

    render :content_type => 'text/html'
      
	end

	#	def new
	#		hobo_new (
	#			begin
	#				@this = Recipe.new
	#				@this.volume = current_user.default_brewery_volume
	#				@this.efficency = current_user.default_brewery_efficency
	#				model = @this
	#			end
	#		)
	#	end

	def create
		@recipe = Recipe.new(params[:recipe])

		if @recipe.save
			flash[:notice] = "Successfully created recipe."
			redirect_to( url_for( :controller => 'recipes', :action => 'edit', :id => @recipe.id ))
		else
			flash[:error] =  @recipe.errors.full_messages {|u| u}.join(', ')
			redirect_to( :action => 'new' )
		end
	end


  def update
		params[:recipe][:existing_fermentable_attributes] ||= {}

		@recipe = Recipe.find(params[:id])

    if !@recipe.updatable_by?(current_user)
      #      flash[:error] = "Update fermentable - permission denied."
      #      update_details_and_fermentables( @recipe )
      notifyattempt(request, "RecipesController.update_og not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

		#Do unit conversions if required.
		params[:recipe][:volume] = BrewingUnits::input_recipe_vol( params[:recipe][:volume], current_user.units.volume ) if params[:recipe][:volume]
    params[:recipe][:og] = BrewingUnits::input_gravity( params[:recipe][:og], current_user.units.gravity ) if  params[:recipe][:og]

		if @recipe.update_attributes(params[:recipe])
			if request.xhr?
        @recipe.save
        @recipe.reload
				# Route to correct update as specified or the whole screen if not.
				case params[:render]
				when "details_and_fermentables"
					update_details_and_fermentables( @recipe )
        when "details_and_hops"
          update_details_and_hops(@recipe)
				else
          render :partial => "recipe_misc"
				end
			else # Updated for a regualar post method.
				flash[:notice] = "Successfully updated recipe and fermentables."
				redirect unless @recipe.update_permitted?
			end
		else
			render :action => 'edit'
		end
	end

  def scale_recipe
    @recipe = Recipe.find(params[:id])
		params[:new_volume] = BrewingUnits::input_recipe_vol( params[:new_volume], current_user.units.volume ) if params[:new_volume]

    #Check units
    @recipe.scale(params[:new_volume],params[:new_eff])
    update_details_and_fermentables( @recipe )
    
  end

	def index
		@recipes = index_recipes_list()

		respond_to do |format|
			format.html
			format.js {
				render :update do |page|
					page.replace_html 'recipe_collecion_div', :partial => 'shared/recipe_collection', :object => @recipes
				end
			}
		end

	end

	def search_form

		unless params[:recipe_filter].blank?
			search_filter = "( name LIKE '%#{params[:recipe_filter]}%' OR description LIKE '%#{params[:recipe_filter]}%')"
			session[:recipeSearchFilter] = search_filter
			logger.debug "Updated search filter: #{search_filter}"
		else
			session[:recipeSearchFilter] = nil
		end


		#Check for style updates
		style_ids = []
		params.each { |key,value|
			style_ids.push(value.to_str)  if key=~/style/
		}

		unless style_ids.empty?
			session[:recipeStyleSelection] = style_ids
			logger.debug "Updated style selection: #{style_ids.join(",")}"
		else
			session[:recipeStyleSelection] = nil
		end

		#Check sort order updates
		case params[:"sort_order"]
		when "Name"
			new_order = "name"
		when "Date"
			new_order = "created_at DESC, name"
		when "Rating"
			new_order = "rating DESC, name"
		else
			new_order = "name"
		end

		session[:recipeOrderBy] = new_order
		logger.debug "Updated style selection: #{new_order}"

		@recipes = index_recipes_list()

		logger.info @recipes.size

		respond_to do |format|
			format.html
			format.js {
				update_search_results( @recipes )
			}
		end
	end

	def brew

		@recipe = Recipe.find(params[:id])

    if current_user.guest?
      flash[:error] = "Guest user cannot create brew entry"
      #render :partial => "recipe_misc"
      redirect_to :action => "show"
      return
    end


    # Need to do in two steps to avoid race condition
		@brew_entry = @recipe.brew_entries.create(:actual_og => @recipe.og,
      :user => current_user )

 		@brew_entry.volume_to_ferementer = @recipe.volume
    @brew_entry.brew_date = Date.today
    @brew_entry.save

		default_brewery = Brewery.default_brewery(current_user)
		logger.debug "Default brewery: #{default_brewery}"

		#Deep copy of recipe to new brew_entry
		@brew_entry.copy_to_actual_recipe( @recipe, default_brewery, current_user )

		#Assign default brewery object to the brew_entry
		@brew_entry.setbrewery(default_brewery) if default_brewery
		@brew_entry.save

		redirect_to :controller => "brew_entries", :action => "show", :id => @brew_entry.id
	end

	def remove_fermentable
		@recipe = Recipe.find(params[:id])

    if !@recipe.updatable_by?(current_user) || !request.xhr?
      #      flash[:error] = "Delete fermentable - permission denied."
      #      update_details_and_fermentables( @recipe )

      notifyattempt(request, "RecipesController.remove_fermentable not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

    old_og = @recipe.og

		Fermentable.delete(params[:comment])
    
		@recipe = Recipe.find(params[:id])
    new_og = @recipe.og
    @recipe.adjust_fixed_hops_for_change(1.0, new_og, old_og)

		update_details_and_fermentables( @recipe )
	end

	def remove_hop
		@recipe = Recipe.find(params[:id])

    if !@recipe.updatable_by?(current_user) || !request.xhr?
      #      flash[:error] = "Delete hop - permission denied."
      #      update_details_and_hops( @recipe )
      notifyattempt(request, "RecipesController.remove_hop not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

		Hop.delete(params[:hop_id])
		update_details_and_hops( @recipe )
	end

	def remove_yeast
		@recipe = Recipe.find(params[:id])

		if !@recipe.updatable_by?(current_user)  || !request.xhr?
      #      flash[:error] = "Delete yeast - permission denied."
      #      update_details_and_yeast( @recipe )
      notifyattempt(request, "RecipesController.remove_yeast not from authorized user: #{current_user}")
      render( :nothing => true )
      return
		end

		Yeast.delete(params[:yeast_id])
		update_details_and_yeast( @recipe )
	end


	def add_fermentable
		@recipe = Recipe.find(params[:id])


    if !(@recipe.fermentables.size() < 15)
      flash[:error] = "Add fermentable - too many fermentables."
      update_details_and_fermentables( @recipe )
      return
		end


		if !@recipe.updatable_by?(current_user) || !request.xhr?
      #      flash[:error] = "Add fermentable - permission denied."
      #      update_details_and_fermentables( @recipe )
      notifyattempt(request, "RecipesController.add_fermentable not from authorized user: #{current_user}")
      render( :nothing => true )
      return
		end

		@fermentable_type = FermentableType.find(params[:ferementable_type_id])

    old_og = @recipe.og

		# Create new fermentable
		@fermentable = @recipe.fermentables.create( :fermentable_type => @fermentable_type, :points => 5.0 )

    new_og = @recipe.og
    @recipe.adjust_fixed_hops_for_change(1.0, new_og, old_og)

		update_details_and_fermentables( @recipe )
	end

	def add_hop
		@recipe = Recipe.find(params[:id])

    if !(@recipe.hops.size() < 15 )
      flash[:error] = "Add hop - too many hop additions."
      update_details_and_hops( @recipe )
      return
    end

    if !@recipe.updatable_by?(current_user)  || !request.xhr?
      #      flash[:error] = "Add hop - permission denied."
      #      update_details_and_hops( @recipe )
      notifyattempt(request, "RecipesController.add_hop not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

		@hop_type = HopType.find(params[:hop_type_id])

		# Create new hop
		@hop = @recipe.hops.create(:hop_type => @hop_type, :ibu_l => 10.0, :minutes => 60, :aa => @hop_type.aa)


		update_details_and_hops( @recipe )
	end

	def add_yeast
		@recipe = Recipe.find(params[:id])

    if !(@recipe.yeasts.size() < 5)
      flash[:error] = "Add yeast - too many yeasts."
      update_details_and_yeast( @recipe )
      return
    end

    if !@recipe.updatable_by?(current_user)  || !request.xhr?
      #      flash[:error] = "Add yeast - permission denied."
      #      update_details_and_yeast( @recipe )
      notifyattempt(request, "RecipesController.add_yeast not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

		@yeast_type = YeastType.find(params[:yeast_type_id])

		# Create new yeast
		@yeast = @recipe.yeasts.create(:yeast_type => @yeast_type, :amount_to_pitch => 1.0)

		update_details_and_yeast( @recipe )
	end


	#	def update_fermentable_points
	#		@recipe =  Recipe.find(params[:id])
	#
	#		#    if !@recipe.updatable_by?(current_user)
	#		#      flash[:error] = "Update - permission denied."
	#		#      update_details_and_fermentables( @recipe )
	#		#      return
	#		#    end
	#
	#		@fermentable = Fermentable.find(params[:fermentable_id])
	#
	#		new_points = params[:points]
	#		new_points = BrewingUnits::input_gravity( new_points, current_user.units.gravity )
	#
	#		logger.debug("update_fermentable_points: new_points #{new_points}")
	#
	#		@fermentable[:points] = new_points
	#		@fermentable.save
	#
	#		update_details_and_fermentables( @recipe )
	#	end
	#
	#	def update_fermentable_weight
	#		@recipe =  Recipe.find(params[:id])
	#
	#		#    if !@recipe.updatable_by?(current_user)
	#		#      flash[:error] = "Update - permission denied."
	#		#      update_details_and_fermentables( @recipe )
	#		#      return
	#		#    end
	#
	#		@fermentable = Fermentable.find(params[:fermentable_id])
	#
	#		# apply conversion for user current units
	#		new_weight = params[:weight]
	#		new_weight = input_fermentable_weight( new_weight )
	#
	#		@fermentable.weight = new_weight
	#
	#		@fermentable.save
	#
	#		update_details_and_fermentables( @recipe )
	#	end
	#
	#	def update_fermentable_per_weight
	#		@recipe =  Recipe.find(params[:id])
	#
	#		#    if !@recipe.updatable_by?(current_user)
	#		#      flash[:error] = "Update - permission denied."
	#		#      update_details_and_fermentables( @recipe )
	#		#      return
	#		#    end
	#
	#		@fermentable = Fermentable.find(params[:fermentable_id])
	#
	#		@fermentable.percentage_weight = params[:per_weight]
	#		@fermentable.save
	#
	#		update_details_and_fermentables( @recipe )
	#	end

	#	def update_og
	#		@recipe =  Recipe.find(params[:id])
	#		#    if !@recipe.updatable_by?(current_user)
	#		#      flash[:error] = "Update - permission denied."
	#		#      update_details_and_fermentables( @recipe )
	#		#      return
	#		#    end
	#		new_og = params[:og]
	#		new_og = BrewingUnits::input_gravity( new_og, current_user.units.gravity )
	#
	#		@recipe.og = new_og
	#		#:todo - need to adjust input for case of Plato settings
	#		@recipe.save
	#
	#		update_details_and_fermentables( @recipe )
	#	end

	#	def update_simple_og
	#		@recipe =  Recipe.find(params[:id])
	#		#    if !@recipe.updatable_by?(current_user)
	#		#      flash[:error] = "Update - permission denied."
	#		#      update_simple
	#		#      return
	#		#    end
	#		new_og = params[:simple_og]
	#		new_og = BrewingUnits::input_gravity( new_og, current_user.units.gravity )
	#
	#		@recipe.simple_og = new_og
	#		#:todo - need to adjust input for case of Plato settings
	#		@recipe.save
	#
	#		update_simple
	#	end
	#
	#	def update_simple_fg
	#		@recipe =  Recipe.find(params[:id])
	#		#    if !@recipe.updatable_by?(current_user)
	#		#      flash[:error] = "Update - permission denied."
	#		#      update_simple
	#		#      return
	#		#    end
	#		new_fg = params[:simple_fg]
	#		new_fg = BrewingUnits::input_gravity( new_fg, current_user.units.gravity )
	#
	#		@recipe.simple_fg = new_fg
	#		#:todo - need to adjust input for case of Plato settings
	#		@recipe.save
	#
	#		update_simple
	#	end
	#
	#    def update_simple_srm
	#		@recipe =  Recipe.find(params[:id])
	#		#    if !@recipe.updatable_by?(current_user)
	#		#      flash[:error] = "Update - permission denied."
	#		#      update_simple
	#		#      return
	#        #    end
	#		new_srm = params[:simple_srm]
	#
	#		@recipe.simple_srm = new_srm
	#		@recipe.save
	#
	#		update_simple
	#	end
	#
	#	def update_simple_ibu
	#		@recipe =  Recipe.find(params[:id])
	#		#    if !@recipe.updatable_by?(current_user)
	#		#      flash[:error] = "Update - permission denied."
	#		#      update_simple
	#		#      return
	#		#    end
	#		new_ibu = params[:simple_ibu]
	#
	#		@recipe.simple_ibu = new_ibu
	#		@recipe.save
	#
	#		update_simple
	#	end

  #	def update_hop_aa
  #		@recipe =  Recipe.find(params[:id])
  #
  #    if !@recipe.updatable_by?(current_user)  || !request.xhr?
  #      #      flash[:error] = "Update - permission denied."
  #      #      update_details_and_hops( @recipe )
  #      notifyattempt(request, "RecipesController.update_hop_aa not from authorized user: #{current_user}")
  #      render( :nothing => true )
  #      return
  #    end
  #		@hop = Hop.find(params[:hop_id])
  #
  #		@hop.aa = params[:aa]
  #		@hop.save
  #
  #		update_details_and_hops( @recipe )
  #	end
  #
  def update_hop_utilisation
    @recipe =  Recipe.find(params[:id])
  
    if !@recipe.updatable_by?(current_user)  || !request.xhr?
      #      flash[:error] = "Update - permission denied."
      #      update_details_and_hops( @recipe )
      notifyattempt(request, "RecipesController.update_hop_utilisation not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end
  
    @recipe.hop_utilisation_method = params[:util_method]
    @recipe.save
  
    update_just_hops( @recipe )
  end
  #
  #
  #	def update_hop_ibu
  #		@recipe =  Recipe.find(params[:id])
  #
  #    if !@recipe.updatable_by?(current_user)  || !request.xhr?
  #      #      flash[:error] = "Update - permission denied."
  #      #      update_details_and_hops( @recipe )
  #      notifyattempt(request, "RecipesController.update_hop_ibu not from authorized user: #{current_user}")
  #      render( :nothing => true )
  #      return
  #    end
  #
  #		@hop = Hop.find(params[:hop_id])
  #
  #		@hop.ibu_l = params[:ibu]
  #		@hop.save
  #
  #		update_details_and_hops( @recipe )
  #	end
  #
  #	def update_hop_weight
  #		@recipe =  Recipe.find(params[:id])
  #
  #    if !@recipe.updatable_by?(current_user)  || !request.xhr?
  #      #      flash[:error] = "Update - permission denied."
  #      #      update_details_and_hops( @recipe )
  #      notifyattempt(request, "RecipesController.update_hop_weight not from authorized user: #{current_user}")
  #      render( :nothing => true )
  #      return
  #    end
  #
  #		@hop = Hop.find(params[:hop_id])
  #
  #		new_weight = params[:weight]
  #		new_weight = input_hops_weight( new_weight )
  #
  #		@hop.weight = new_weight
  #		@hop.save
  #
  #		update_details_and_hops( @recipe )
  #	end
  #
  #	def update_hop_minutes
  #		@recipe =  Recipe.find(params[:id])
  #
  #    if !@recipe.updatable_by?(current_user)  || !request.xhr?
  #      #      flash[:error] = "Update - permission denied."
  #      #      update_details_and_hops( @recipe )
  #      notifyattempt(request, "RecipesController.update_hop_minutes not from authorized user: #{current_user}")
  #      render( :nothing => true )
  #      return
  #    end
  #
  #		@hop = Hop.find(params[:hop_id])
  #
  #		new_minutes = params[:minutes]
  #		new_minutes = -1.0 if new_minutes.upcase.first == "D"  # Convert from dried hop value
  #
  #		@hop.minutes = new_minutes
  #		@hop.save
  #
  #		update_details_and_hops( @recipe )
  #	end

	#	def change_recipe_type
	#
	#		logger.debug "change_recipe_type called"
	#		@recipe =  Recipe.find(params[:id])
	#
	#		if @recipe.is_simple? then
	#			@recipe.update_attribute( :recipe_type, :calculated.to_s )
	#		else
	#			@recipe.update_attribute( :recipe_type, :simple.to_s )
	#		end
	#
	#		update_recipe_main
	#	end
	#
	#	def upload_recipe_file
	#		@recipe = Recipe.find(params[:id])
	#		@recipe.uploaded_recipe_file = params[:recipe_file]
	#		@recipe.save
	#
	#		update_simple
	#	end


	def add_mash_step
		@recipe = Recipe.find(params[:id])

    if !(@recipe.mash_steps.size() < 10)
      flash[:error] = "Add mash step - too many mash steps."
      render_mashsteps( @recipe )
      return
    end

    if !@recipe.updatable_by?(current_user)  || !request.xhr?
      #      flash[:error] = "Add mash step - permission denied."
      #      render_mashsteps( @recipe )
      notifyattempt(request, "RecipesController.add_mash_step not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

		# Create new hop
		@mashstep = @recipe.mash_steps.create(:name => 'Sacchrification', :steptype => 'infusion', :time => 60, :temperature => 67.0)


		render_mashsteps( @recipe )
	end

	def update_mashstep
		@recipe = Recipe.find(params[:id])

		@mash_step = MashStep.find(params[:mashstep_id])

    if !@recipe.updatable_by?(current_user)  || !request.xhr?
      #      flash[:error] = "Edit mash step - permission denied."
      #      render_mashsteps( @recipe )
      notifyattempt(request, "RecipesController.update_mashstep not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

		@mash_step.attributes = params[:mash_step]

		#Convert temperature in regards to proper unit.
		@mash_step.temperature = input_temperature( @mash_step.temperature )
		@mash_step.steptype = :direct.to_s unless @mash_step.steptype # Make sure it has a value

		@mash_step.save

		render_mashsteps( @recipe)

	end

	def  remove_mashstep
		@recipe = Recipe.find(params[:id])

    if !@recipe.updatable_by?(current_user)  || !request.xhr?
      #      flash[:error] = "Delete yeast - permission denied."
      #      render_mashsteps( @recipe )
      notifyattempt(request, "RecipesController.remove_mashstep not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

		MashStep.delete(params[:mashstep_id])
		render_mashsteps( @recipe)
	end


	def add_misc
		@recipe = Recipe.find(params[:id])

    if !(@recipe.misc_ingredients.size() < 10)
      flash[:error] = "Add misc - too many misc ingredients."
      render_misc( @recipe )
      return
    end


    if !@recipe.updatable_by?(current_user) || !request.xhr?
      #      flash[:error] = "Add misc - permission denied."
      #      render_misc( @recipe )
      notifyattempt(request, "RecipesController.add_misc not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

		# Create new hop
		@misc = @recipe.misc_ingredients.create()


		render_misc( @recipe )
	end

	#	def update_misc
	#		@recipe = Recipe.find(params[:id])
	#
	#		@misc = MiscIngredient.find(params[:misc_id])
	#
	##		if !@recipe.updatable_by?(current_user)
	##			flash[:error] = "Edit mash step - permission denied."
	##			update_details_and_hops( @recipe )
	##			return
	##		end
	#
	#		@misc.attributes = params[:misc_ingredient]
	#
	#		#Convert temperature in regards to proper unit.
	#		#@mash_step.temperature = input_temperature( @mash_step.temperature )
	#		#@mash_step.steptype = :direct.to_s unless @mash_step.steptype # Make sure it has a value
	#
	#		@misc.save
	#
	#		render_misc( @recipe)
	#
	#	end

	def  remove_misc

		@recipe = Recipe.find(params[:id])

    if !@recipe.updatable_by?(current_user) || !request.xhr?
      #      flash[:error] = "Delete misc - permission denied."
      #      render_misc( @recipe )
      notifyattempt(request, "RecipesController.remove_misc not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

		MiscIngredient.delete(params[:misc_id])
		render_misc( @recipe)
	end

	
	def clone
		logger.debug( current_user )

    if current_user.guest?
      #      flash[:error] = "Delete misc - permission denied."
      #      render_misc( @recipe )
      notifyattempt(request, "RecipesController.clone as guest user")
      render( :nothing => true )
      return
    end

		@recipe = Recipe.find(params[:id])
		logger.debug( @recipe.user )

		#Clone recipe
		new_recipe = @recipe.deep_clone

		#Ensure that ownership is changed
		new_recipe.user = current_user


		#Updated to make sure that parent or recipe is recorded.
		new_recipe.genealogy = @recipe.id.to_s
		new_recipe.genealogy = @recipe.genealogy  + "." + @recipe.id.to_s if @recipe.genealogy

		#Append users name to title to make them think about changing it.
		new_recipe.name = current_user.name + " - " + new_recipe.name

		now = Time.new
		new_recipe.created_at = now
		new_recipe.updated_at = now

		new_recipe.save

		redirect_to( url_for( :controller => 'recipes', :action => 'edit', :id => new_recipe.id ) )

	end

  def del_recipe
    @recipe = Recipe.find(params[:id])

    if !@recipe.updatable_by?(current_user)
      #      flash[:error] = "Edit mash step - permission denied."
      #      render_mashsteps( @recipe )
      notifyattempt(request, "RecipesController.update_mashstep not from authorized user: #{current_user}")
      render( :nothing => true )
      return
    end

    @recipe.destroy

    redirect_to "/"

  end



end


