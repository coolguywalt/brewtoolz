class RecipeUserShared < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps

    # -- invite status
    shared_state enum_string(:invited, :accepted)

    # -- edit permissions
    can_edit :boolean
    can_invite :boolean
    can_update_message_log :boolean
    can_email_group :boolean

    #-- notification rules
    notification_type enum_string(:daily_updates, :weekly_updates, :no_udpates)
    last_notified :datetime
    last_viewed :datetime
    
  end

  belongs_to :recipe_shared
  belongs_to :user
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

  def can_remove( user )
    return true if ( self.user == user )
    return true if (recipe_shared.recipe.user == user)
    return false
  end

  def stale_view?( user )
    return false unless user

    #locate user.
    return false unless last_viewed

    return (last_viewed < recipe_shared.last_updated)
  end

end
