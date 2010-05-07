class RecipeShared < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
    last_updated :datetime
  end


  belongs_to :recipe
  # belongs_to :user, :creator => true

  has_many :recipe_user_shared, :dependent => :destroy

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

  def can_edit( user )
    logger.debug "++ recipe_shared.can_edit - checking user: #{user}"

    shared_record = recipe_user_shared.find_by_user_id( user.id)

    return false unless shared_record

    return shared_record.can_edit
     
  end

  #Used to mark when the user has last looked at this shared recipe
  def sharer_viewed( user )
    
    logger.debug "++ recipe_shared.sharer_viewed - checking user: #{user}"
    shared_record = recipe_user_shared.find_by_user_id( user.id)
    return unless shared_record

    shared_record.last_viewed = Time.now()
    shared_record.save

  end

  def updated_since?( time )

    logger.debug "++updated_since: time #{time}"

    return false unless time
    return false unless last_updated

    logger.debug "++updated_since: last_updated #{last_updated}"

    return (time < last_updated)
  end

  def mark_update( time=nil )
    time = DateTime.now unless time
    self.last_updated = time
    save
  end


  def stale_view?( user )
    return false unless user

    #locate user.
    shared_record = recipe_user_shared.find_by_user_id( user.id)
    return false unless shared_record

    return shared_record.stale_view?(user)
  end
end
