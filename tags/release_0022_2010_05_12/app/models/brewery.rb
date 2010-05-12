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

class Brewery < ActiveRecord::Base

	hobo_model # Don't put anything above this

	fields do
		name :string

		description :text
		capacity :float
		efficency :float
		isDefault :boolean
		isAllGrain :boolean

		liquor_to_grist :float
		boil_time :integer
		mash_tun_capacity :float
		mash_tun_deadspace :float

		evapouration_rate :float
		boiler_loses :float


		timestamps
	end

	validates_numericality_of :capacity, :greater_than => 0.0
	validates_numericality_of :efficency, :greater_than => 0.0, :less_than => 120.0

	belongs_to :user, :creator => true
	# --- Permissions --- #

	def create_permitted?
		acting_user.administrator? || acting_user.signed_up?
	end

	def update_permitted?
		user_is? acting_user || acting_user.administrator?
	end

	def destroy_permitted?
		acting_user.administrator?
	end

	def view_permitted?(field)
		user_is? acting_user || acting_user.administrator?
	end


	def initialize(params = nil)
		super
		self.capacity = 23.0
		self.efficency = 75.0
	end

    def self.default_brewery(user)
		logger.debug "user: #{user}"
		default_breweries =  Brewery.find_all_by_user_id(user.id, :conditions => "isDefault = true", :limit => 1)
		return default_breweries[0] if default_breweries[0]

		#return a reference brewery, not one that is owned by the user.

		logger.debug "Creating default session brewery."

		def_brewery = Brewery.new(
			:capacity => 23.0,
			:efficency => 75.0,
			:liquor_to_grist => 3.0,
			:boil_time => 60,
			:mash_tun_capacity => 44.0,
			:mash_tun_deadspace => 2.0,

			:evapouration_rate => 4.0,
			:boiler_loses => 2.0
		)

		return def_brewery
	end

end
