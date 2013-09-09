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

class User < ActiveRecord::Base

	hobo_user_model # Don't put anything above this

	fields do
		name :string, :unique, :login => true, :name => true
		email_address :email_address
		administrator :boolean, :default => false
		default_locked_recipes :boolean, :default => false
		last_activity :integer
		timestamps
	end

	has_many :recipes
	has_many :breweries  # a user can have more that one brewery setup.
    has_many :brew_entries
	has_one :ingredient_unit_preference

	has_many :fermentable_inventories
	has_many :hops_inventories
	has_many :kit_inventories
	has_many :yeast_inventories
	has_many :fermentable_inventory_items, :through => :fermentable_inventories, :source => :fermentable_type

	# This gives admin rights to the first sign-up.
	# Just remove it if you don't want that
	before_create { |user| user.administrator = true if RAILS_ENV != "test" && count == 0 }
  
  
	# --- Signup lifecycle --- #

	lifecycle do
  
		state :active, :default => true

		create :signup, :available_to => "Guest",
		  :params => [:name, :email_address, :password, :password_confirmation],
		  :become => :active

		transition :request_password_reset, { :active => :active }, :new_key => true do
			UserMailer.deliver_forgot_password(self, lifecycle.key)
		end

		transition :reset_password, { :active => :active }, :available_to => :key_holder,
		  :params => [ :password, :password_confirmation ]

	end


	# --- Permissions --- #

	def create_permitted?
		false
	end

	def update_permitted?
		acting_user.administrator? || (acting_user == self )
		# Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
		# directly from a form submission.
	end

	def destroy_permitted?
		acting_user.administrator?
	end

	def view_permitted?(field)
		true
	end

	def edit_permitted?(attribute)
		return false if ((attribute ==  :administrator) && !acting_user.administrator? )
		return false if ((attribute ==  :name) && !acting_user.administrator? )

		(acting_user == self  or acting_user.administrator?)
	end

	def get_default_brewery
		breweries.each do |abrewery|
			return abrewery if abrewery.isDefault
		end

		return breweries[1]
	end

	def default_brewery_volume
		thebrewery = get_default_brewery

		logger.debug "default brewery: #{thebrewery}"

		return 23.0 unless thebrewery
		return thebrewery.capacity
	end

	def default_brewery_efficency
		thebrewery = get_default_brewery
		return 75.0 if !thebrewery
		return thebrewery.efficency
	end

	def units
		create_ingredient_unit_preference() unless ingredient_unit_preference
		return ingredient_unit_preference
	end


	def is_online?
		return false unless last_activity
		return (10.minutes.ago.to_i < last_activity)
	end

end
