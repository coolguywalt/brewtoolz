#    This file is part of Brewtools.
#
#    Brewtools is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Brewtools is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with Brewtools.  If not, see <http://www.gnu.org/licenses/>.
#
#    Copyright Chris Taylor, 2008, 2009, 2010

class Hop < ActiveRecord::Base

	hobo_model # Don't put anything above this

  include ApplicationModelsHelper

	fields do
		minutes :integer
		aa :float

		ibu_l :float # IBU per liter
		dry_hop_amount_l :float # Only used for dry hopping or flame out addtions (amount per litre)
		notes :text

    lock_weight :boolean

		#Items for future consideration from BeerXML
		#Mandatory
		#NAME Text Name of the hops
		# => This item is covered by the hop_type parent item.
		#VERSION Integer Should be set to 1 for this version of the XML standard.  May be a higher number for later versions but all later versions shall be backward compatible.
		#ALPHA Percentage Percent alpha of hops - for example "5.5" represents 5.5% alpha
		#AMOUNT Weight (kg) Weight in Kilograms of the hops used in the recipe.
		#USE List May be "Boil", "Dry Hop", "Mash", "First Wort" or "Aroma".  Note that "Aroma" and "Dry Hop" do not contribute to the bitterness of the beer while the others do.  Aroma hops are added after the boil and do not contribute substantially to beer bitterness.
    # Note added a hop_tea entry in for french press hopping.

		hop_use enum_string(:boil, :dry_hop, :mash, :first_wort, :aroma, :hop_tea)
		#TIME Time (min) The time as measured in minutes.  Meaning is dependent on the “USE” field.  For “Boil” this is the boil time.  For “Mash” this is the mash time.  For “First Wort” this is the boil time.  For “Aroma” this is the steep time.  For “Dry Hop” this is the amount of time to dry hop.
		#Optional fields
		#NOTES Text Textual notes about the hops, usage, substitutes.  May be a multiline entry.
		#TYPE List May be "Bittering", "Aroma" or "Both"
		hop_use_type enum_string(:bittering, :aroma, :both)
		#FORM List May be "Pellet", "Plug" or "Leaf"
		hop_form enum_string(:pellet, :plug, :leaf)
		#BETA Percentage Hop beta percentage - for example "4.4" denotes 4.4 % beta
		beta :float
		#HSI Percentage Hop Stability Index - defined as the percentage of hop alpha lost in 6 months of storage
		#ORIGIN Text Place of origin for the hops
		#SUBSTITUTES Text Substitutes that can be used for this hops
		#HUMULENE Percent Humulene level in percent.
		humulene :float
		#CARYOPHYLLENE Percent Caryophyllene level in percent.
		caryophllene :float
		#COHUMULONE Percent Cohumulone level in percent
		cohumulone :float
		#MYRCENE Percent Myrcene level in percent
		myrcene :float

		timestamps
	end


	belongs_to :recipe
	belongs_to :hop_type

	validates_numericality_of :aa, :greater_than => 0.0
	validates_numericality_of :minutes
	validates_numericality_of :ibu_l, :greater_than_or_equal_to => 0

  $CUBED_MINS_OFFSET = 20  # Additional minutes to add when doing calculations for a cubed recipe.

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

  def adjusted_mins( mins=nil, is_cubed=nil )
    return read_attribute(:minutes) if (recipe.nil? and mins.nil?) #Possible on hop creation scenario
    is_cubed = false if (recipe.nil? and is_cubed.nil?) #Corner case when recipe object is still nill for creation scenario


    mins = read_attribute(:minutes) if mins.nil?
    is_cubed = recipe.is_cubed? if is_cubed.nil?

    return mins + (is_cubed ? $CUBED_MINS_OFFSET : 0)
  end

  def weight=( new_weight )

		if (no_utilisation?) then
			logger.debug "setting dry hop weight"
			write_attribute(:dry_hop_amount_l, (Float(new_weight)/recipe.volume) )
			return
		end

		new_ibu_l = ibu_l_from_weight(new_weight)
		write_attribute(:ibu_l, new_ibu_l)
    #rescue
    #	write_attribute(:ibu_l, new_weight)  # do this to cause validation errors to be propigated
	end

	def weight
		#    if( recipe.total_points > 50 ) then
		#       cgravity = 1.0 + ((recipe.total_points-50)/1000 / 0.2)
		#    else
		#       cgravity = 1.0
		#    end
		#
		#    logger.debug("cgravity: " + cgravity.to_s)
		logger.debug "recipe: #{recipe}"

		logger.debug "recipe.volume: #{recipe.volume}"
		logger.debug "utilisation: #{utilisation(recipe.total_points, minutes, recipe.hop_utilisation_method)}"

		return (dry_hop_amount_l ? dry_hop_amount_l : 0.0) * recipe.volume if no_utilisation?
		wgrams = (recipe.volume * ibu_l) / (utilisation(recipe.total_points, adjusted_mins, recipe.hop_utilisation_method) * (aa/100) * 1000.0)

		return wgrams
	end

	def percentage_ibu
		return 0.0 unless minutes > 0  # Filter for 0 minute and dry hopped addtions
		return ibu_l / recipe.ibu
	end



	def utilisation( points, time, method )

		logger.debug "Params: points: #{points}, time: #{time}, method: #{method}"

    return 0.0 if time <= 0.0

		return utilisation_rager(points, time) if method == :rager.to_s
		# return utilisation_garetz(points, time) if method == :garetz.to_s
		return utilisation_tinseth(points, time)

	end

	#  def utilisation_garetz( points, time )
	#    # yet to be implemented
	#    return 0.01
	#  end

	def utilisation_rager( points, time )
		# Approximation of the rager forumla
		utilisation = (18.11 + 13.86 * Math.tanh((time-31.32)/18.27))/100.0
		logger.debug "Rager: Utilisation: #{utilisation}"

		#Adjustment for higher gravity
		gravity_adjustment = 0.0
		gravity_adjustment = ((points-50)/1000)/0.2 if points > 50

		adjusted_utilisation = utilisation/(1+gravity_adjustment)

		logger.debug "Rager: Adjusted Utilisation: #{adjusted_utilisation}"

		return adjusted_utilisation
	end


	def utilisation_tinseth( points, time)

		# return 0 if @minutes <= 0 Takes accound of flame out and dry hop additions.

		#tinseth method
		#    decimal alpha acid utilization = Bigness factor * Boil Time factor
		#
		#The Bigness factor accounts for reduced utilization due to higher wort gravities. Use an average gravity value for the entire boil to account for changes in the wort volume.
		#
		#Bigness factor = 1.65 * 0.000125^(wort gravity - 1)
		#
		#The Boil Time factor accounts for the change in utilization due to boil time:
		#
		#Boil Time factor = 1 - e^(-0.04 * time in mins)
		#                   --------------------------
		#                             4.15

		bigness_factor = 1.65 * (0.000125 ** (Float(points)/1000))
		boil_time_factor = (1 - Math.exp( -0.04 * Float(time) )) / 4.15

		logger.debug( "Utilisation: #{bigness_factor * boil_time_factor}")

		return bigness_factor * boil_time_factor

	end

	def minutes=(new_minute)
    logger.debug "++minutes="

    set_minutes(new_minute)

	end



	#def minutes
  # return "D" if read_attribute(:minutes) < 0 #Special case for dry hopping
	#  return read_attribute(:minutes)
	#end

	#def ibu_l
	#  return 0.0 if dry_hopped?
	#  return read_attribute(:ibu_l)
	#end

	def ibu_l=(new_ibu_l)
    
    is_dry_hopped = dry_hopped?
		write_attribute(:ibu_l, new_ibu_l) unless is_dry_hopped
    #Ensure that ibu_l is not left nil
    write_attribute(:ibu_l, 0.0) if is_dry_hopped

	end

	#Determine if beer is late hopped or dry hopped
	def dry_hopped?
		return (hop_use == :dry_hop || hop_use == :hop_tea)
	end

	def ibu_l_from_weight( aweight )
		logger.debug "++ibu_l_from_weight aweight: #{aweight}"

		new_ibu = (Float(aweight) * utilisation(recipe.total_points, adjusted_mins, recipe.hop_utilisation_method) * aa/100.0 * 1000.0)

		logger.debug "new_ibu: #{new_ibu}"

		new_ibu_l = new_ibu / recipe.volume
		return new_ibu_l
	end


	def number_with_precision(number, precision=3)
		"%01.#{precision}f" % number
	rescue
		number
	end

  #Factor up or down hop amounts/ibu_l
  def adjust( factor )

    if dry_hopped?
      new_dry_hop_amount_l = dry_hop_amount_l * factor
      write_attribute(:dry_hop_amount_l, new_dry_hop_amount_l )
    else
      new_ibu_l = ibu_l * factor
      write_attribute(:ibu_l, new_ibu_l)
    end

  end

  def lock_weight
    return is_weight_locked?
  end

  def is_weight_locked?
    wla = read_attribute(:lock_weight)
    return is_weight_locked_func?( wla, recipe)
  end

  def no_utilisation?
    return (self[:ibu_l] <= 0.0)
  end

  def adjust_for_cubing( is_cubed )
    logger.debug "++adjust_for_cubing"
    logger.debug "Recipe is cubed?: #{is_cubed}"
    logger.debug "Readjusting weights for hop: #{self}, dhamnt: #{dry_hop_amount_l}, ibu_l: #{ibu_l}, minutes: #{minutes}, adj_mins: #{adjusted_mins(minutes,is_cubed)} "
    set_minutes( minutes, is_cubed ) # resets the minutes and recalcs the weights according to the hop_cubed recipe setting.
    logger.debug "After weights for hop: #{self}, dhamnt: #{dry_hop_amount_l}, ibu_l: #{ibu_l} "
  end

  protected

  def set_minutes( new_minute, is_cubed=nil  )
    logger.debug( "Setting minutes from: #{self.minutes} to #{new_minute}" )

    dry_hop_ammnt = dry_hop_amount_l || 0.0
    new_minute = new_minute.to_i
    adj_new_minute = adjusted_mins(new_minute, is_cubed ) #Take into account offset for no chill method.

    if adjusted_mins == adj_new_minute  #Nothing to do
      logger.debug "No update required asjusted_mins:#{adjusted_mins} adj_new_minute:#{adj_new_minute}"
      return
    end

    logger.debug( "Adjusted new minutes #{adj_new_minute}" )

		if recipe.nil? 	#special case where recipe is not yet defined (when used with the recipe.hops.create method
      write_attribute(:minutes, new_minute)
      return
    end

    old_weight = self.weight

		#Flip around for case where now dryhopping.
		if( (dry_hop_ammnt <= 0) and (adj_new_minute <= 0) ) then
			logger.debug( "Changing to dryhopped" )

		  #theweight_l = read_attribute(:ibu_l) / (utilisation(recipe.total_points, minutes, recipe.hop_utilisation_method) * (aa/100) * 1000.0)
      theweight_l = old_weight / recipe.volume
			write_attribute(:dry_hop_amount_l, theweight_l )
			write_attribute(:ibu_l, 0.0)

		end

		#Flip around to non-dry hopped
		if( (dry_hop_ammnt > 0) and (adj_new_minute > 0) ) then
			logger.debug( "Changing from dryhopped" )
			logger.debug( "Dry hop amaount per ltr: #{dry_hop_ammnt}" )

			new_ibu_l = (dry_hop_ammnt * utilisation(recipe.total_points, adj_new_minute, recipe.hop_utilisation_method) * aa/100.0 * 1000.0)
      logger.debug "New ibu per liter: #{new_ibu_l}"
			write_attribute(:ibu_l, new_ibu_l )
			write_attribute(:dry_hop_amount_l, 0.0 )

		end

    logger.debug "Writing new minutes value to db"
		write_attribute(:minutes, new_minute)
  end

end
