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

class MiscIngredient < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
	  name :string
	  misc_type enum_string(:spice, :fining, :wateragent, :herb, :flavor, :other)
	  misc_use enum_string(:boil, :mash, :primary, :secondary, :bottling)
	  time :float #unit is minutes. Amount of time the misc was boiled, steeped, mashed, etc in minutes.
	  amount_l :float #dependant on solid of liquid type for units
	  is_solid :boolean #true if it is a solid
	  use_for :string #for description on usage.
	  notes :text #comment for usage.
    timestamps
  end

belongs_to :recipe

#BeerXML format
#
#Data tag	Format	Description
#MISC	Record	Starts a misc ingredient record -- any of the below tags may be included in any order within the <MISC>…. </MISC> record tags.  Any non-standard tags in the misc will be ignored.
#NAME	Text	Name of the misc item.
#VERSION	Integer	Version number of this element.  Should be “1” for this version.
#TYPE	List	May be “Spice”, “Fining”, “Water Agent”, “Herb”, “Flavor” or “Other”
#USE	List	May be “Boil”, “Mash”, “Primary”, “Secondary”, “Bottling”
#TIME	Time (min)	Amount of time the misc was boiled, steeped, mashed, etc in minutes.
#AMOUNT	Volume (l) or Weight (kg)	Amount of item used.  The default measurements are by weight, but this may be the measurement in volume units if AMOUNT_IS_WEIGHT is set to TRUE for this record.  If a liquid it is in liters, if a solid the weight is measured in kilograms.
#AMOUNT_IS_WEIGHT	Boolean	TRUE if the amount measurement is a weight measurement and FALSE if the amount is a volume measurement.  Default value (if not present) is assumed to be FALSE.
#USE_FOR	Text	Short description of what the ingredient is used for in text
#NOTES	Text	Detailed notes on the item including usage.  May be multiline.





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

  def amount
	  return 0.0 unless amount_l
	  return amount_l * recipe.volume
  end
end
