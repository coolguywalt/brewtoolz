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
    return kit_type.kit_points( brewery_capacity, quantity )
  end

  def percentage_points
		return 0.0 if recipe.total_points <= 0.0

		per_gravity = points / recipe.total_points
		return per_gravity
  end

  def percentage_ibu
		return 0.0 if recipe.ibu <= 0.0

		per_ibu = ibus / recipe.ibu
		return per_ibu
  end

  def ibus
    brewery_capacity = recipe.volume || brewery_capacity = 23.0
    return kit_type.kit_ibus( brewery_capacity, quantity )
  end

  def weight
    return 0.0 unless kit_type.weight
    return kit_type.weight * quantity
  end

  def kit_volume
    return 0.0 unless kit_type.volume
    return kit_type.volume * quantity
  end

end
