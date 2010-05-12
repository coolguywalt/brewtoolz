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

class IngredientUnitPreference < ActiveRecord::Base

  hobo_model # Don't put anything above this

  require 'brewing_units'

  fields do

	hops :string
    fermentable :string
    volume :string
    wateradditions :string
    temperature :string
    gravity :string
    liquor_to_grist :string

    hop_utilisation_method enum_string(:tinseth, :rager, :garetz)

    timestamps
  end

  belongs_to :user, :creator => true


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
    user_is? acting_user|| acting_user.administrator?
  end

  # Initialization method to ensure valid values for newly created preferences.
  def initialize(*)
	  super

      self.hop_utilisation_method = :tinseth.to_s

	  # Pick of both metric an imperial, so that anon guest will show both
	  self.hops = $GRAMS + " " + $OUNCE
      self.fermentable = $GRAMS + " " + $POUND
      self.volume = $LITRE + " " + $GALLON
      self.wateradditions = $GRAMS  + " " + $OUNCE
      self.temperature = $CELCIUS + " " + $FARENHEIT
      self.gravity = $SGRAVITY
      self.liquor_to_grist = $LTR_PER_KG


  end


  # Accessors for providing default vaules ... should be depricated.
  def hops
    self[:hops] or $GRAMS
  end

  def fermentable
    self[:fermentable] or $GRAMS
  end

  def volume
    self[:volume] or $LITRE
  end

  def wateradditions
    self[:wateradditions] or $GRAMS
  end

  def temperature
    self[:temperature] or $CELCIUS
  end

  def gravity
    self[:gravity] or $SGRAVITY
  end

  def hop_utilisation_method
    self[:hop_utilisation_method] or :tinseth.to_s
  end

  def liquor_to_grist
    self[:liquor_to_grist] or $LTR_PER_KG
  end

  def unit_type=(value)
    logger.debug "Value: #{value}"
    logger.debug "Constant: #{$METRIC}"

    if value == $METRIC then
      logger.debug "assigning metric values"

      self.hops = $GRAMS
      self.fermentable = $GRAMS
      self.volume = $LITRE
      self.wateradditions = $GRAMS
      self.temperature = $CELCIUS
      self.gravity = $SGRAVITY
      self.liquor_to_grist = $LTR_PER_KG
    end

    if value == $IMPERIAL then
      self.hops = $OUNCE
      self.fermentable = $POUND
      self.volume = $GALLON
      self.wateradditions = $OUNCE
      self.temperature = $FARENHEIT
      self.gravity = $SGRAVITY
      self.liquor_to_grist = $QUARTS_PER_LB
    end

    if value == ($IMPERIAL + " " + $METRIC) then
      self.hops = $OUNCE + " " + $GRAMS
      self.fermentable = $POUND + " " + $GRAMS
      self.volume = $GALLON + " " + $LITRE
      self.wateradditions = $OUNCE + " " + $GRAMS
      self.temperature = $FARENHEIT + " " + $CELCIUS
      self.gravity = $SGRAVITY
      self.liquor_to_grist = $QUARTS_PER_LB
    end

    if value == ($METRIC + " " + $IMPERIAL) then
      self.hops = $GRAMS + " " + $OUNCE
      self.fermentable = $GRAMS + " " + $POUND
      self.volume = $LITRE + " " + $GALLON
      self.wateradditions = $GRAMS  + " " + $OUNCE
      self.temperature = $CELCIUS + " " + $FARENHEIT
      self.gravity = $SGRAVITY
      self.liquor_to_grist = $LTR_PER_KG
    end

    #save() # save the record to the database.

  end


end
