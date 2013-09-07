class KitInventory < ActiveRecord::Base

	hobo_model # Don't put anything above this

	fields do

		amount :float
		balance :float
		comment :text

		location :string
		label :string

		source_date :datetime

		timestamps
	end

	belongs_to :kit_type
	belongs_to :user, :creator => true

	has_many :kit_inventory_log_entries, :dependent => :destroy

	named_scope :viewable, lambda {|acting_user| {:conditions => {:user_id => "#{acting_user.id}" } } }
    named_scope :not_spent, :conditions => 'balance > 0.0'
    named_scope :owned_by, lambda { |auser| {:conditions => ['user_id = ?', auser] } } 

	validates_presence_of :kit_type
	validates_numericality_of :amount, :greater_than_or_equal_to => 0.0
	validates_numericality_of :balance, :greater_than_or_equal_to => 0.0

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
		return kit_type.name
	end

	def age
		return 0 unless source_date
		return source_date
		#return Time.zone.now.to_date - source_date.to_date
	end

    def is_can?
		return (self.kit_type == :can.to_s)
	end

	def is_fresh_wort?
		return (self.kit_type == :freshwort.to_s)
	end


	# Proxy methods through to kit_type for convenance
	def kit_ibus( target_volume, quantity = 1.0 )
		kit_type.kit_ibus(target_volume, quantity)
	end

	def kit_points( target_volume, quantity = 1.0 )
		kit_type.kit_points(target_volume, quantity)
	end

	def volume
		kit_type.volume
	end

	def weight
		kit_type.weight
	end

	def designed_volume
		kit_type.designed_volume
	end

    def self.amount_units( user )
        return ""
    end

    def balance=( new_balance )
        # Initialise original amount for the first time balance is updated.
        amount = new_balance if amount == 0.0
    end
end
