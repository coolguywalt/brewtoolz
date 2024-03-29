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

class Yeast < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
	amount_to_pitch :float # Estimated number of healthy cells required
    amount_to_pitch_min :float
    amount_to_pitch_max :float
    notes :text

    timestamps
  end

  belongs_to :recipe
  belongs_to :yeast_type
    def ingr_type
        return self.yeast_type
    end

    def ingr_type=(new_yeast_type)
       self.yeast_type = new_yeast_type 
    end

    has_many :yeast_inventory_log_entries
    def log_entries
        return self.yeast_inventory_log_entries
    end


    named_scope :list, :include => :yeast_type, :order => "yeast_types.name"

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

end
