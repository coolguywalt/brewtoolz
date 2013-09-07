class FermentableInventory < ActiveRecord::Base

    hobo_model # Don't put anything above this

    include BrewingUnits 
    
    fields do

        amount :float
        balance :float
        comment :text

        location :string
        label :string

        source_date :datetime

        timestamps
    end

    belongs_to :fermentable_type
    belongs_to :user, :creator => true

    has_many :fermentable_inventory_log_entries, :dependent => :destroy

    named_scope :viewable, lambda {|acting_user| {:include => :fermentable_type, :conditions => {:user_id => "#{acting_user.id}"} } }

    # The following scope is required to support search on the associated fermentable_type.name attribute and the limitations of the
    # hobonet table-plus search capabilities.
    named_scope :viewable_search, lambda {|acting_user, search| {:include => :fermentable_type,
        :conditions => "(fermentable_inventories.user_id = #{acting_user.id}) AND ((fermentable_types.name LIKE \'%#{search}%\') OR (comment LIKE \'%#{search}%\'))" } }

    named_scope :not_spent, :conditions => 'balance > 0.0'
    named_scope :owned_by, lambda { |auser| {:conditions => ['user_id = ?', auser] } } 
    named_scope :oldestfirst, :order =>  "source_date ASC"

    validates_presence_of :fermentable_type
    validates_numericality_of :amount, :greater_than_or_equal_to => 0.0
    validates_numericality_of :balance, :greater_than_or_equal_to => 0.0

    # --- Permissions --- #

    def name
        return fermentable_type.name
    end

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

    def age
        #return 0 unless source_date
        return source_date
        #return Time.zone.now.to_date - source_date.to_date
    end

    def weight
        return amount
    end

    def fermentable_selections( user )

    end

    def self.amount_units( user )
        return "[" + BrewingUnits::units_for_display( user.units.fermentable ) + "]"
    end


end
