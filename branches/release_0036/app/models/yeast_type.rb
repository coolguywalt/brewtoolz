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

class YeastType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    description :text
    min_temp :float
    max_temp :float
    flocculation :string
    attenuation :float
    alcohol_tollerance :string

    validated :boolean

    timestamps
  end

  validate_on_update :check_temp_values?
  validates_numericality_of :attenuation, :less_than => 100.0, :greater_than => 0.0

  belongs_to :user, :creator => true

  default_scope :order => 'name'

  after_create :reset_validation_to_false
  before_update :reset_validation_to_false_if_not_admin

  def check_temp_values?
    errors.add(:min_temp, "must be less then max temp.") unless min_temp <= max_temp
  end


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
