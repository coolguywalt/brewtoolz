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

class BrewEntryLog < ActiveRecord::Base

	hobo_model # Don't put anything above this

	include RecipeCalcs

	fields do

		log_date :datetime
		comment :text
		log_type enum_string(:observation, :tasting, :evaluation)
		specific_gravity :float
		temperature :float
		rating :integer

		timestamps
	end

	belongs_to :brew_entry
	belongs_to :user, :creator => true

	validates_numericality_of :specific_gravity, :greater_than_or_equal_to => -10.0, :unless  => Proc.new { |r| !r.specific_gravity }
	validates_numericality_of :rating, :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 50
	# validates_numericality_of :temperature

	# --- Permissions --- #

	def create_permitted?
		acting_user.administrator?
	end

	def update_permitted?
    
		user_is? acting_user || acting_user.administrator?
	end

	def destroy_permitted?
		acting_user.administrator?
	end

	def view_permitted?(field)
		true
	end

	def age
		#distance_of_time_in_words(log_date.to_date, brew_entry.bottled_kegged )
		log_date.to_date - brew_entry.bottled_kegged
	end

	def isobservation
		return (log_type == "observation")
	end

	def istasting
		return (log_type == "tasting")
	end

    def attenuation
		attenuation = calc_attenuation(brew_entry.actual_og,specific_gravity)
		return attenuation
    end

    def abv
		abv_value = calc_abv(brew_entry.actual_og,specific_gravity)
		return abv_value
    end


    def rating=( new_rating )
		#@rating = new_rating
		write_attribute(:rating, new_rating)

		brew_entry.recalc_rating()
    end
  

end
