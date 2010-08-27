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

class KitType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    points :float
    yeild :float
    ibus :float
    colour :float   # note colour is in EBC units
    volume :float   
    weight :float   
    description :text

    designed_volume :float

    kit_type enum_string(:can, :freshwort)

    validated :boolean  #Used to mark if a moderator has done a quality check of the information.

    timestamps
  end

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

  def validated_edit_permitted?
    logger.debug "validated_edit_permitted?  acting_user.administrator?: #{acting_user.administrator?}"

    return acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

  def is_can?
    return (self.kit_type == :can.to_s)
  end

  def is_fresh_wort?
    return (self.kit_type == :freshwort.to_s)
  end

  def kit_points( target_volume, quantity=1.0 )
    #Calculate gravity contribution in current recipe volume
    return 0.0 unless target_volume

    if is_can? then
      lb_per_kg =  2.2046226
      gal_per_ltr = 0.264172052

      gu_lb_gal = yeild/100.0 * 46.2
      weight_in_lbs = weight/1000.0 * quantity * lb_per_kg


      #weight_in_lbs = points / (gu_lb_gal)
      #weight_in_lbs / (brewery_capacity * gal_per_ltr) = points / (gu_lb_gal)
      calc_points = weight_in_lbs * gu_lb_gal / (target_volume * gal_per_ltr)

      #calc_points = weight_in_lbs / (gu_lb_gal) * brewery_capacity * gal_per_ltr
      return calc_points
    end

    if is_fresh_wort? then
      calc_points = points * quantity * target_volume / volume

      return calc_points
    end

    #Should not get here .. means the data for the kit is incorrect
    return 0.0
  end

  def kit_ibus( target_volume, quantity=1.0 )

    return 0.0 unless target_volume
    if is_can? then
      # Assume ibu is per kg ltr as per beer xml
      calc_ibu = ibus * weight/1000.0 * quantity / target_volume
      return calc_ibu
    end

    if is_fresh_wort? then
      # Assume ibu is per the volume in the wort kit
      calc_ibu = ibus * quantity * volume / target_volume
      return calc_ibu
    end

    #Should never get here.
    return 0.0

  end

  protected

  #Cheap hack to ensure that newly created records are marked as requiring to be validated.
  def reset_validation_to_false
    self.validated = false
    return true
  end

  def reset_validation_to_false_if_not_admin
    return true if acting_user.administrator?
    return reset_validation_to_false
  end
end
