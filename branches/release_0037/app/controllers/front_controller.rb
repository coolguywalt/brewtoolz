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


class FrontController < ApplicationController


	include ApplicationHelper

	hobo_controller

	def index; end

	def search
		if params[:query]
			site_search(params[:query])
		end
	end

	def loadsharedrecipes
		shared_recipes = brewers_shared_recipes(current_user)
		if shared_recipes.size > 0
			render :partial => 'shared/recipe_list_shared', :object => shared_recipes

		else
			render :inline => %{<p>No shared recipes to display</p>}
		end
	end

	def loadbrewlogs
		render :partial => 'shared/brewentry_list_scrollable', :object => brewers_logs(current_user)
	end

	def paginate_brewers_recipe_list
        recipe_list = brewers_recipes_paginated(current_user, session[:brewersRecipeFilter])

		render :update do |page|
			page.replace_html 'paginated_recipe_list_div', :partial => 'shared/recipe_list_paginated', :object => recipe_list
		end
	end

	def search_brewers_recipes
		filter = nil
		filter =  params[:brewers_recipe_filter] unless params[:brewers_recipe_filter].blank?
		session[:brewersRecipeFilter] = filter

	    recipe_list = brewers_recipes_paginated(current_user, filter)

		render :update do |page|
			page.replace_html 'paginated_recipe_list_div', :partial => 'shared/recipe_list_paginated', :object => recipe_list
		end
	end

end
