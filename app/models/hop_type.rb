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

class HopType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    description :text
    aa :float

#Items for future consideration from BeerXML
#Mandatory
#NAME Text Name of the hops
# => This item is covered by the hop_type parent item.
#VERSION Integer Should be set to 1 for this version of the XML standard.  May be a higher number for later versions but all later versions shall be backward compatible.
#ALPHA Percentage Percent alpha of hops - for example "5.5" represents 5.5% alpha
#AMOUNT Weight (kg) Weight in Kilograms of the hops used in the recipe.
#USE List May be "Boil", "Dry Hop", "Mash", "First Wort" or "Aroma".  Note that "Aroma" and "Dry Hop" do not contribute to the bitterness of the beer while the others do.  Aroma hops are added after the boil and do not contribute substantially to beer bitterness.
	hop_use enum_string(:boil, :dry_hop, :mash, :first_wort, :aroma)
#TIME Time (min) The time as measured in minutes.  Meaning is dependent on the “USE” field.  For “Boil” this is the boil time.  For “Mash” this is the mash time.  For “First Wort” this is the boil time.  For “Aroma” this is the steep time.  For “Dry Hop” this is the amount of time to dry hop.
#Optional fields
#NOTES Text Textual notes about the hops, usage, substitutes.  May be a multiline entry.
#TYPE List May be "Bittering", "Aroma" or "Both"
    hop_use_type enum_string(:bittering, :aroma, :both)
#FORM List May be "Pellet", "Plug" or "Leaf"
   #form(:pellet, :plugs, :leaf)
#BETA Percentage Hop beta percentage - for example "4.4" denotes 4.4 % beta
	beta :float
#HSI Percentage Hop Stability Index - defined as the percentage of hop alpha lost in 6 months of storage
	hsi :float
#ORIGIN Text Place of origin for the hops
	origin :text
#SUBSTITUTES Text Substitutes that can be used for this hops

#HUMULENE Percent Humulene level in percent.
	humulene :float
#CARYOPHYLLENE Percent Caryophyllene level in percent.
	caryophllene :float
#COHUMULONE Percent Cohumulone level in percent
	cohumulone :float
#MYRCENE Percent Myrcene level in percent
	myrcene :float

    validated :boolean

	timestamps
  end

  #Substitute hop modelling

  has_many   :substitutes,
             :class_name => "HopType" ,
             :foreign_key => "substitute_hop_id"

  validates_numericality_of :aa, :greater_than => 0.0

  belongs_to :user, :creator => true

  default_scope :order => 'name'

  after_create :reset_validation_to_false
  before_update :reset_validation_to_false_if_not_admin

  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

 def update_permitted?
    return true if acting_user.administrator?
    #return true if (user_is? acting_user)
    return true if (user_is? acting_user) and (none_changed? :validated)
    return false
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

  protected

  #Cheap hack to ensure that newly created records are marked as requiring to be validated.
  def reset_validation_to_false
    logger.debug "Setting validated to false"
    self.validated = false
    return true
  end

  def reset_validation_to_false_if_not_admin
    return if acting_user.administrator?
    return reset_validation_to_false
  end

end
