class YeastInventory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do

    amount :float
    comment :text

    location :string
    label :string

    source_date :datetime

    storage_type enum_string(:slant, :yeast_cake, :package)

    timestamps
  end

  belongs_to :yeast_type
  belongs_to :user, :creator => true

  has_many :yeast_inventory_log_entries, :dependent => :destroy


  named_scope :viewable, lambda {|acting_user| {:conditions => {:user_id => "#{acting_user.id}" } } }

  validates_presence_of :yeast_type
  validates_numericality_of :amount, :greater_than_or_equal_to => 0.0

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
    return yeast_type.name
  end

  def age
    return 0 unless source_date
    return source_date
    #return Time.zone.now.to_date - source_date.to_date
  end
end
