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

# To change this template, choose Tools | Templates
# and open the template in the editor.

module ApplicationModelsHelper


  def is_weight_locked_func?( weight_lock, recipe)

    return true if recipe.locked

    logger.debug "Checking lock weight attribute"
    return weight_lock unless weight_lock.nil?

    #Default to false for a recipe, or a brew recipe that is still in planning phase (before brewday)
    logger.debug "Checking for planned brew"
    return false unless recipe.is_brewday?       #Defalt to false for a normal recipe.
    return false if recipe.is_brewday_planning?  #Default to false in planning phase

    logger.debug "Brewday not in planning"
    #Default to lock if currently brewing or fermenting
    return true
  end
end
