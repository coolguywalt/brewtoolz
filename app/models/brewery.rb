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

                bicarbonate :float
                calcium :float
                carbonate :float
                chloride :float
                fluoride :float
                iron :float
                magnesium :float
                nitrate :float
                nitrite :float
                pH :float
                potassium :float
                sodium :float
                sulfate :float
                total_alkalinity :float

		timestamps
	end

	validates_numericality_of :capacity, :greater_than => 0.0
	validates_numericality_of :efficency, :greater_than => 0.0, :less_than => 120.0
        validates_numericality_of :bicarbonate,
                                  :greater_than_or_equal_to => 0.0
        validates_numericality_of :calcium, :greater_than_or_equal_to => 0.0
        validates_numericality_of :carbonate, :greater_than_or_equal_to => 0.0
        validates_numericality_of :chloride, :greater_than_or_equal_to => 0.0
        validates_numericality_of :fluoride, :greater_than_or_equal_to => 0.0
        validates_numericality_of :iron, :greater_than_or_equal_to => 0.0
        validates_numericality_of :magnesium, :greater_than_or_equal_to => 0.0
        validates_numericality_of :nitrate, :greater_than_or_equal_to => 0.0
        validates_numericality_of :nitrite, :greater_than_or_equal_to => 0.0
        validates_numericality_of :pH, :greater_than_or_equal_to => 0.0,
                                  :less_than_or_equal_to => 14.0
        validates_numericality_of :potassium, :greater_than_or_equal_to => 0.0
        validates_numericality_of :sodium, :greater_than_or_equal_to => 0.0
        validates_numericality_of :sulfate, :greater_than_or_equal_to => 0.0
        validates_numericality_of :total_alkalinity,
                                  :greater_than_or_equal_to => 0.0

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

	DEFAULT_BREWERY = {
		:capacity => 23.0,
		:efficency => 75.0,
		
		:liquor_to_grist => 3.0,
		:boil_time => 60,
		:mash_tun_capacity => 44.0,
		:mash_tun_deadspace => 2.0,

		:evapouration_rate => 4.0,

                :bicarbonate => 292.0,
              	:calcium => 80.0,
               	:carbonate => 0.0,
               	:chloride => 118.0,
               	:fluoride => 0.0,
               	:iron => 0.0,
               	:magnesium => 31.0,
               	:nitrate => 16.4,
               	:nitrite => 0.0,
               	:pH => 7.0,
               	:potassium => 6.0,
               	:sodium => 86.0,
               	:sulfate => 96.0,
               	:total_alkalinity => 239.0
	}

	RO_BREWERY = {
		:capacity => 23.0,
		:efficency => 75.0,
		:liquor_to_grist => 3.0,
		:boil_time => 60,
		:mash_tun_capacity => 44.0,
		:mash_tun_deadspace => 2.0,

		:evapouration_rate => 4.0,
		:boiler_loses => 2.0,

        	:bicarbonate => 16.0,
        	:calcium => 1.0,
        	:carbonate => 0.0,
        	:chloride => 4.0,
        	:fluoride => 0.0,
        	:iron => 0.0,
        	:magnesium => 0.0,
        	:nitrate => 0.0,
        	:nitrite => 0.0,
        	:pH => 7.0,
        	:potassium => 0.0,
        	:sodium => 8.0,
        	:sulfate => 1.0,
        	:total_alkalinity => 13.1
	}

	def initialize(params = nil)
		super
		self.capacity = DEFAULT_BREWERY[:capacity] 
		self.efficency = DEFAULT_BREWERY[:efficency] 
		
		self.liquor_to_grist = DEFAULT_BREWERY[:liquor_to_grist] 
		self.boil_time = DEFAULT_BREWERY[:boil_time] 
		self.mash_tun_capacity = DEFAULT_BREWERY[:mash_tun_capacity] 
		self.mash_tun_deadspace = DEFAULT_BREWERY[:mash_tun_deadspace] 

		self.evapouration_rate = DEFAULT_BREWERY[:evapouration_rate] 

                self.bicarbonate = DEFAULT_BREWERY[:bicarbonate] 
              	self.calcium = DEFAULT_BREWERY[:calcium]
               	self.carbonate = DEFAULT_BREWERY[:carbonate]
               	self.chloride = DEFAULT_BREWERY[:chloride]
               	self.fluoride = DEFAULT_BREWERY[:fluoride]
               	self.iron = DEFAULT_BREWERY[:iron]
               	self.magnesium = DEFAULT_BREWERY[:magnesium]
               	self.nitrate = DEFAULT_BREWERY[:nitrate]
               	self.nitrite = DEFAULT_BREWERY[:nitrite]
               	self.pH = DEFAULT_BREWERY[:pH]
               	self.potassium = DEFAULT_BREWERY[:potassium]
               	self.sodium = DEFAULT_BREWERY[:sodium]
               	self.sulfate = DEFAULT_BREWERY[:sulfate]
               	self.total_alkalinity = DEFAULT_BREWERY[:total_alkalinity]
	end

    def self.default_brewery(user)
		logger.debug "user: #{user}"
		default_breweries =  Brewery.find_all_by_user_id(user.id, :conditions => "isDefault = true", :limit => 1)
		return default_breweries[0] if default_breweries[0]

		#return a reference brewery, not one that is owned by the user.

		logger.debug "Creating default session brewery."

		def_brewery = Brewery.new(  DEFAULT_BREWERY )

		return def_brewery
	end

    def self.ro_brewery()
		return Brewery.new( RO_BREWERY )
    end
end
