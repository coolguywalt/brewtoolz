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
    validated :boolean  #Used to mark if a moderator has done a quality check of the information.
    acidity_type enum_string(:base, :crystal, :roast, :acid), :default => :base

    timestamps
  end

  validates_numericality_of :colour, :greater_than_equal_to => 0.0
  validates_numericality_of :yeild, :greater_than_equal_to => 0.0

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

#  def validated_edit_permitted?
#    logger.debug "validated_edit_permitted?  acting_user.administrator?: #{acting_user.administrator?}"
#
#    return acting_user.administrator?
#  end

#  def validated_view_permitted?
#    return true if acting_user.administrator?
#    return false
#  end


  def summary
    summary_str = "Yeild: " + yeild.to_s + " Is converted: " + converted.to_s + " Colour: " + colour.to_s
  end

  def mashed
    m = read_attribute(:mashed)  #Default to true if the item has not been defined yet.
    return true if m == nil
    return m
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
