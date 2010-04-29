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

class KitType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    points :float
    yeild :float
    ibus :float
    colour :float   # note colour is in EBC units
    volume :float   
    weight :float   
    description :text

    designed_volume :float

    kit_type enum_string(:can, :freshwort)

    timestamps
  end


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

  def is_can?
    return (self.kit_type == :can.to_s)
  end

  def is_fresh_wort?
    return (self.kit_type == :freshwort.to_s)
  end
end
