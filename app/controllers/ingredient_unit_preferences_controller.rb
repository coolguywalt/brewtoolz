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

class IngredientUnitPreferencesController < ApplicationController

  hobo_model_controller


 auto_actions :all, :except => [ :index, :create, :show]#, :show, :edit ]

  def show
    # should not show these elements outside the context of the preference screen
    #redirect_to :back
    redirect_back_or_default(nil)
  end

  def update_unit_type
    logger.debug params

    @ingredient_unit_preference =  IngredientUnitPreference.find(params[:id])
    @ingredient_unit_preference.unit_type = params[:unit_type]

    render :partial => 'preferences', :object => @ingredient_unit_preference
  end

end
