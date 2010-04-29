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

class Kit < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do

    quantity :float

    timestamps
  end

  validates_numericality_of :quantity , :greater_than => 0.0, :message => "Quantity must be a number > 0"


  belongs_to :recipe
  belongs_to :kit_type
  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

  def points
    #Calculate gravity contribution in current recipe volume
    brewery_capacity = recipe.volume || brewery_capacity = 23.0

    if kit_type.is_can? then
      lb_per_kg =  2.2046226
      gal_per_ltr = 0.264172052

      gu_lb_gal = kit_type.yeild/100.0 * 46.2
      weight_in_lbs = kit_type.weight/1000.0 * quantity * lb_per_kg

      
      #weight_in_lbs = points / (gu_lb_gal)
      #weight_in_lbs / (brewery_capacity * gal_per_ltr) = points / (gu_lb_gal)
      calc_points = weight_in_lbs * gu_lb_gal / (brewery_capacity * gal_per_ltr)
      
      #calc_points = weight_in_lbs / (gu_lb_gal) * brewery_capacity * gal_per_ltr
      return calc_points
    end

    if kit_type.is_fresh_wort? then
      calc_points = kit_type.points * quantity * kit_type.volume / brewery_capacity

      return calc_points
    end

    #Should not get here .. means the data for the kit is incorrect
    return 0.0
  end

  def percentage_points
		return 0.0 if recipe.total_points <= 0.0

		per_gravity = points / recipe.total_points
		return per_gravity
  end

  def percentage_ibu
		return 0.0 if recipe.ibu <= 0.0

		per_ibu = ibu / recipe.ibu
		return per_ibu
  end

  def ibu

    brewery_capacity = recipe.volume || brewery_capacity = 23.0

    if kit_type.is_can? then
      # Assume ibu is per kg ltr as per beer xml
      calc_ibu = kit_type.ibus * kit_type.weight/1000.0 * quantity / brewery_capacity
      return calc_ibu
    end

    if kit_type.is_fresh_wort? then
      # Assume ibu is per the volume in the wort kit
      calc_ibu = kit_type.ibus * quantity * kit_type.volume / brewery_capacity
      return calc_ibu
    end

    #Should never get here.
    return 0.0

  end

  def weight
    return kit_type.weight * quantity
  end

end
