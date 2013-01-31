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

class MashStep < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    temperature :float
    time :integer
    liquor_to_grist :float
    steptype enum_string(:direct, :infusion, :decoction)

    addition_amount :float
    addition_temp :float

    timestamps
  end

	belongs_to :recipe

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

  def self.default()
    thedefault = MashStep.new(
    	:name => "Saccrification",
      :temperature => 67.0,
      :time => 60,
	    :liquor_to_grist => 3.2,
	    :steptype => "direct",
      :addition_amount => 0.0,
      :addition_temp => 0.0
    )
  end

end
