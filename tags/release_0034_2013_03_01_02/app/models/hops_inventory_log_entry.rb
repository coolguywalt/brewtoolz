class HopsInventoryLogEntry < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    amount :float
    note :text
    usagetime :datetime

    timestamps
  end


  belongs_to :brew_entry
  belongs_to :hops_inventory
  belongs_to :user, :creator => true

  validate :inventory_capacity?

  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    return true if acting_user.administrator?
    return true if user_is? acting_user
    return false
  end

  def destroy_permitted?
    return true if acting_user.administrator?
    return true if user_is? acting_user
    return false
  end

  def view_permitted?(field)
    true
  end

  def inventory_capacity?
    if hops_inventory.amount.to_f < amount.to_f

      #fermentable_inventory.errors.add(:amount, "must not be greater than stored amount." )
      errors.add(:amount, "must not be greater than the inventory amount stored." )
    end

  end

end
