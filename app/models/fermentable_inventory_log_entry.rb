class FermentableInventoryLogEntry < ActiveRecord::Base

    hobo_model # Don't put anything above this

    fields do
        amount :float
        note :text
        usagetime :datetime

        timestamps
    end

    belongs_to :fermentable_inventory
    belongs_to :fermentable_type
    def ingr_type=( newfermtype )
        self.fermentable_type = newfermtype 
    end
    def ingr_type
        self.fermentable_type
    end
    belongs_to :fermentable

    belongs_to :user, :creator => true
    belongs_to :recipe
    
    validate :inventory_capacity?
    validates_numericality_of :amount

    def inventory= ( newInventory )
        self.fermentable_inventory = newInventory
    end

    def inventory 
        return self.fermentable_inventory 
    end

    def ingr= ( newIngr )
        self.fermentable = newIngr
    end
    
    def ingr 
        return fermentable 
    end
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
        if amount.to_f < 0 then
            errors.add(:amount, "must be greater than 0." )
            return
        end

        diff = 0.0
        diff = amount.to_f - amount_was unless amount_was.nil?

        if diff > fermentable_inventory.balance 
            logger.debug "++inventory_capacity? - amount exceeded"
            errors.add(:amount, "must not be greater than the inventory amount stored." )
        end

    end

end
