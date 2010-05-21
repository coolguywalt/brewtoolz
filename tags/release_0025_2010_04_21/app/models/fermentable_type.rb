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

class FermentableType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    yeild :float
    converted :boolean
    fullyfermentable :boolean
    mashed :boolean
    colour :float   # note colour is in EBC units
    description :text

    timestamps
  end

  validates_numericality_of :colour, :greater_than_equal_to => 0.0
  validates_numericality_of :yeild, :greater_than_equal_to => 0.0



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

  def summary
    summary_str = "Yeild: " + yeild.to_s + " Is converted: " + converted.to_s + " Colour: " + colour.to_s
  end

  def mashed
    m = read_attribute(:mashed)  #Default to true if the item has not been defined yet.
    return true if m == nil
    return m
  end
end
