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

end
