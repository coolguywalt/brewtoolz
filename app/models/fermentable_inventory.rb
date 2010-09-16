class FermentableInventory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do

    amount :float
    comment :text

    location :string
    label :string

    source_date :datetime

    timestamps
  end

  belongs_to :fermentable_type
  belongs_to :user, :creator => true

  has_many :fermentable_inventory_log_entries, :dependent => :destroy



  named_scope :viewable, lambda {|acting_user| {:conditions => {:user_id => "#{acting_user.id}" } } }

  validates_presence_of :fermentable_type
  validates_numericality_of :amount, :greater_than => 0.0
  
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

  def amount
    db_amount = read_attribute(:amount)
    #    logger.debug "FermentableInventory.amount: acting_user #{acting_user}"
    #
    #    return db_amount if acting_user.guest?

    #Adjust according to users unit preferences.
    return UnitsHelper::ferm_weight_value( db_amount, user )
  end

  def amount=(new_amount)
    adjusted_amount = new_amount

    adjusted_amount = UnitsHelper::input_fermentable_weight( new_amount, user )
    
    write_attribute( :amount, adjusted_amount )

  end
end
