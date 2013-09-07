class HopsInventory < ActiveRecord::Base

    hobo_model # Don't put anything above this

    include BrewingUnits 

    fields do

        amount :float
        balance :float
        comment :text

        location :string
        label :string

        source_date :datetime

        aa :float

        hop_form enum_string(:pellet, :plug, :leaf)

        timestamps
    end

    belongs_to :hop_type
    def invent_type
       return self.hop_type 
    end
    belongs_to :user, :creator => true
    has_many :hops_inventory_log_entries, :dependent => :destroy

    named_scope :viewable, lambda {|acting_user| {:conditions => {:user_id => "#{acting_user.id}" } } }
    named_scope :not_spent, :conditions => 'balance > 0.0'
    named_scope :owned_by, lambda { |auser| {:conditions => ['user_id = ?', auser] } }
    named_scope :oldestfirst, :order =>  "source_date ASC"

    validates_presence_of :hop_type
    validates_numericality_of :amount, :greater_than_or_equal_to => 0.0
    validates_numericality_of :balance, :greater_than_or_equal_to => 0.0
    validates_numericality_of :aa, :greater_than => 0.0
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
        return true if acting_user.administrator?
        return true if user_is? acting_user
        return false
    end


    def name
        return hop_type.name
    end

    def age
        return 0 unless source_date
        return source_date
        #return Time.zone.now.to_date - source_date.to_date
    end

    def self.amount_units( user )
        return "[" + BrewingUnits::units_for_display( user.units.hops ) + "]"
    end
    
    def balance=( new_balance )
        # Initialise original amount for the first time balance is updated.
        amount = new_balance if amount == 0.0
        write_attribute( :balance, new_balance )
    end
    
    def has_allocation_to_another? ( ingr )
        
        #return false if ingr.log_entries.empty?
        logger.debug "++has_allocation_to_another: ingr: #{ingr}"

        #  Find all the hops that have the same hop type and same minutes.
        ingr_list = ingr.recipe.hops.find( :all, :conditions => "id <> #{ingr.id} and hop_type_id =#{ingr.hop_type_id} and minutes = #{ingr.minutes}")

        logger.debug "++has_allocation_to_another: ingr_list.count: #{ingr_list.count}"

        ingr_list.each do |ahop|
            # See if this inventory is used by one of these additions.
            return true if ahop.log_entries.find( :all, 
                    :conditions => "hops_inventory_id = #{self.id} and amount > 0" ).count > 0
        end
        
        return false
        #inv_log_class = Object.const_get("#{ingr.class.name.gsub('Hop','Hops')}InventoryLogEntry")
        #inv_log_class.find( :all, :conditions => 
        #    "recipe_id = #{ingr.recipe.id} and #{ingr.class.name.underscore}_id <> #{ingr.id} and hops_inventory_id <> #{id} and amount > 0.0" ).count > 0
    end
end
