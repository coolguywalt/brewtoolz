class HopsInventoryLogEntry < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    amount :float
    note :text
    usagetime :datetime

    timestamps
  end

  belongs_to :hops_inventory
  def inventory
      return self.hops_inventory
  end

  belongs_to :hop_type
  def ingr_type=( newhoptype )
    self.hop_type = newhoptype 
  end
  def ingr_type
    self.hop_type
  end

  belongs_to :hop  

  belongs_to :user, :creator => true
  belongs_to :recipe

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
    
      return if amount_was.nil?

      unless hops_inventory.balance.to_f >= (amount.to_f - amount_was)
         errors.add(:amount, "must not be greater than the inventory amount stored." )
      end

  end

    # should have used STI but this will do to give semblance of polymorphism for now.
    def ingr= ( newIngr )
        logger.debug "hops_inventory.ingr= #{newIngr}" 
        self.hop = newIngr
    end
    def ingr 
        return hop 
    end

    def inventory= ( newInventory )
        logger.debug "hops_inventory.inventory= #{newInventory}" 
        self.hops_inventory = newInventory
    end
    def inventory 
        return self.hops_inventory 
    end

end
