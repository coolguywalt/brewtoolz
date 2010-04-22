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

class Recipe < ActiveRecord::Base

  hobo_model # Don't put anything above this

  include RecipeCalcs
  include UnitsHelper

  fields do
    name :string

    description :text
    genealogy :string   # designates the parentage of the recipe if it was cloned or modified.

    # -- reference elements used for calculating weights etc.
    volume :float
    efficency :float

    # -- cached value, derived from brewlogs.  Too expensive to recalc dynamically
    rating :float

    hop_utilisation_method enum_string(:tinseth, :rager, :garetz)

    hop_cubed :boolean


    locked :boolean  #Signifies all ingredients should be considered locked.

    # -- simple recipe representation that does not have ingredients assigned
    #    could be a placeholder for something done in the past, or for an uploaded
    #    recipe from another brewing calculator software.
    recipe_type enum_string(:simple, :calculated)

    #    simple_og :float
    #    simple_fg :float
    #    simple_ibu :float
    #    simple_srm :float
    #    simple_yeast :string
    #
    #    simple_recipe_filename :string
    #    simple_recipe_content_type :string
    #    simple_recipe_filedata :binary,  :limit => 2.megabyte
	
    timestamps
  end

  belongs_to :user, :creator => true
  belongs_to :style
  belongs_to :brew_entry # used to cache copy of actual recipe brewed and isolates changes made
  # at a latter point in time.
						 
  has_many :fermentables, :dependent => :destroy, :uniq => true
  has_many :hops, :dependent => :destroy
  has_many :yeasts, :dependent => :destroy
  has_many :misc_ingredients, :dependent => :destroy
  has_many :kits, :dependent => :destroy
  has_many :brew_entries, :dependent => :destroy
  has_many :mash_steps, :dependent => :destroy

  has_one :recipe_shared, :dependent => :destroy

  #before_destroy :pre_destroy


  # --- Permissions --- #

  def create_permitted?
    acting_user.signed_up?

  end

  def update_permitted?
    logger.debug "++update_permitted?"
	  logger.debug "Acting user: #{acting_user}"
	  user_is? acting_user or acting_user.administrator? or shared_edit?
  end

  def destroy_permitted?
    logger.debug "++destroy_permitted?"
    logger.debug "Acting user: #{acting_user}"
    return true if (acting_user && acting_user.administrator?)
    return true if (user_is? acting_user) && (created_at > (Date.today()-14))  # Give a user two weeks to be able to delete a recipe.
    return false
  end

  def view_permitted?(field)
    true
  end

  def edit_permitted(attribute)
	  user_is? acting_user or acting_user.administrator? or shared_edit?
  end

  def is_shared?
    return false unless recipe_shared
    return false unless recipe_shared.recipe_user_shared.count > 0
    return true
  end

  def shared_edit?
    logger.debug "++ shared.edit?"

    return false unless recipe_shared
    return recipe_shared.can_edit(acting_user)
  end

  def is_owner?
    user_is? acting_user
  end

  def initialize(params = nil)
    super
    if self.user
      self.volume = user.default_brewery_volume unless self.volume
      self.efficency = user.default_brewery_efficency unless self.efficency
      self.hop_utilisation_method = user.units.hop_utilisation_method unless hop_utilisation_method
      self.locked = user.default_locked_recipes
    else
      self.volume = 23.0 unless self.volume
      self.efficency = 75.0 unless self.efficency
      self.hop_utilisation_method = :tinseth.to_s unless hop_utilisation_method
    end
    self.recipe_type = :calculated.to_s
  end

  def deep_clone

    logger.debug "++deep_clone"
    new_recipe = self.clone()
    new_recipe.save()

    #Copy owned associations
    fermentables.each { |fermentable|
      next unless fermentable
      logger.debug "Fermentable attributes: #{fermentable.attributes()}"
      f = new_recipe.fermentables.create!( fermentable.attributes() )
      if fermentable[:lock_weight].nil?
        f[:lock_weight] = nil  # Hack to avoid nil value being traslated into a 0
        f.save
      end
    }

    hops.each { |hop|
      next unless hop
      logger.debug "Hops attributes: #{hop.attributes()}"
      h = new_recipe.hops.create!( hop.attributes() )

      if hop[:lock_weight].nil?
        h[:lock_weight] = nil  # Hack to avoid nil value being traslated into a 0
        h.save
      end

    }

    yeasts.each{ |yeast|
      next unless yeast
      new_recipe.yeasts.create!( yeast.attributes() )
    }


    mash_steps.each{ |mash_step|
      next unless mash_step
      new_recipe.mash_steps.create!( mash_step.attributes() )
    }

    misc_ingredients.each{ |misc|
      next unless misc
      new_recipe.misc_ingredients.create!( misc.attributes() )
    }
    return new_recipe
  end

  def validate

    # Validation for the virual attribute :og
    if(@submitted_og) then
      begin
        og_value = Float( @submitted_og )
        errors.add(:og, "must be geater than 0") if (og_value < 0)
      rescue
        logger.debug "og format error"
        errors.add(:og, "must be a number")
      end
    end

  end

  def new_fermentable_attributes=(fermentable_attributes)
    fermentable_attributes.each do |attributes|
      fermentables.build(attributes)
    end
  end

  def existing_fermentable_attributes=(fermentable_attributes)
    fermentables.reject(&:new_record?).each do |fermentable|
      attributes = fermentable_attributes[fermentable.id.to_s]
      if attributes
        fermentable.attributes = attributes
        #else -- required if non-referenced attributes to be deleted.
        #   fermentables.delete(fermentable)
      end
    end
  end

  def og
    return total_points
  end

  def og=( new_og)
    # No argument so just ignore
    return unless new_og

    new_og_f = 0.0
    @submitted_og = new_og
    logger.debug "new_og: #{new_og}"

    # Check supplied value is a number
    begin
      new_og_f = Float( new_og )
    rescue
      logger.debug "og format error"
      #   errors.add(:recipe, "og must be a number")
      @submitted_og = new_og
      return
    end

    logger.debug "new_og_f: #{new_og_f}"

    # Check greater than 0
    if( new_og_f <= 0 ) then
      logger.debug "og less then 0"
      #   errors.add(:recipe, "og must be greater than 0")
      return
    end

    ratio_change = new_og_f/total_points

    old_og = total_points

    fermentables.each do |fermentable|
      next unless fermentable
      fermentable.points *= ratio_change
      fermentable.save
    end

    adjust_fixed_hops_for_change(1.0, new_og, old_og)

  end

  def fg
    fg = og

    att = yeast_attenuation
    att = 75 if att == 0.0
    att = att/100.0

    fermentables.each do |fermentable|
      next unless fermentable
      next unless fermentable.fermentable_type

      logger.debug "fermentable: #{fermentable}"

      if fermentable.fermentable_type.fullyfermentable then
        fg -= fermentable.points * 0.98 # Fudge factor as not even sugar is fully fermentable
      else
        fg -= fermentable.points * att
      end
    end

    return fg
  end

  def srm
    # MCU = (Weight of grain in lbs) * (Color of grain in degrees lovibond) / (volume in gallons)
    # SRM color = 1.4922 * (MCU ** 0.6859)

    srm_total =0.0

    fermentables.each do |fermentable|
      next unless fermentable
      next unless fermentable.fermentable_type

      # srm_contrib = srm_contrib + fermentable.weight.to_f
      mcu = (gms_to_lbs(fermentable.weight) * (fermentable.fermentable_type.colour/1.97)) / ltrs_to_gal( volume )
      logger.debug( "fermentable: #{fermentable.fermentable_type.name}  mcu: #{mcu}")

      srm_total += mcu
    end

    if( srm_total > 1) then
      srm_total = 1.4922 * (srm_total ** 0.6859)

      logger.debug( "srm total: #{srm_total}")
    end

    return srm_total
  end

  def ebc
    return srm * 1.97  # Conversion factor for SRM to EBC
  end

  def ibu
    total_ibu = 0.0
    hops.each do |hop|
      next unless hop
      total_ibu += hop.ibu_l
    end
    return total_ibu
  end

  def abv
    abv_value = calc_abv(og,fg)
    return sprintf( "%.2f", abv_value )
  end

  def total_weight
    total_weight = 0.0
    fermentables.each do |fermentable|
      next unless fermentable
      total_weight = total_weight + fermentable.weight.to_f
    end
    return total_weight
  end

  def total_mash_weight
    total_mash_weight = 0.0
    fermentables.each do |fermentable|
      #assume fully fermentable items (ie sugar) not mashed.
      next unless fermentable
      next unless fermentable.fermentable_type

      total_mash_weight = total_mash_weight + fermentable.weight.to_f if fermentable.fermentable_type.mashed
    end
    return total_mash_weight
  end

  def total_points
    total_points = 0.0
    fermentables.each do |fermentable|
      next unless fermentable
      total_points += fermentable.points
    end
    return total_points
  end

  def total_mash_points
    total_points = 0.0
    fermentables.each do |fermentable|
      next unless fermentable
      total_points += fermentable.points if fermentable.fermentable_type.mashed
    end
    return total_points
  end

  def yeast_attenuation
    attenuation = 0.0
    yeasts.each do |yeast|
      next unless yeast
      next unless yeast.yeast_type
      attenuation = yeast.yeast_type.attenuation if attenuation < yeast.yeast_type.attenuation
    end
    return attenuation
  end

  def attenuation
    return calc_attenuation(og,fg)
  end

  def bugu
    return ibu/og
  end

  def rte
    # Calculates the beers real terminal extract
    return calc_rte(og, fg)
  end

  def balance
    return calc_balance(og, fg, ibu)
  end

  def recalc_rating
    rating_total = 0.0
    rating_count = 0

    brew_entries.reload

    brew_entries.each do |brew_entry|
      next unless brew_entry
      next unless brew_entry.ave_rating > 0.0
      rating_total += brew_entry.ave_rating
      rating_count += 1
    end

    new_rating = 0.0
    new_rating = rating_total/rating_count if rating_count > 0
    new_rating = -1.0 if rating_count == 0  # set to invalid result if no brew entries


    logger.debug("New rating: #{new_rating}")

    @rating = new_rating

    # Should not update attributes for records that have not yet been created.
    update_attribute( :rating, new_rating) unless new_record?

  end

  def brews_completed()
    today = Date.today
    condition = "brew_date < '" + today.to_s + "'"
    brew_entries.count( :conditions => condition )
  end

  def rating
    cur_rating = read_attribute(:rating)
    logger.debug "self.rating: #{cur_rating}"
    recalc_rating if cur_rating == nil # if null then do a recalc to intialise the rating.
    return read_attribute(:rating)
  end

  def uploaded_recipe_file=(recipe_file_field)
    self.simple_recipe_filename  = base_part_of(recipe_file_field[:uploaded_recipe_file].original_filename)
    self.simple_recipe_content_type = recipe_file_field[:uploaded_recipe_file].content_type.chomp
    self.simple_recipe_filedata = recipe_file_field[:uploaded_recipe_file].read
  end

  def base_part_of(file_name)
    File.basename(file_name).gsub(/[^\w._-]/, '' )
  end

  def recipe_file_type_istext?
    return false unless self.simple_recipe_content_type
    return self.simple_recipe_content_type.to_s == "text/plain"
  end

  def recipe_file_text
    lines =""
    self.simple_recipe_filedata.to_s.each_line { |line|
      lines += line + "\n"
    }

    return lines
  end

  def volume
    logger.debug "volume brew_entry: #{brew_entry}"

    return read_attribute(:volume) unless brew_entry  # If this is a brewentry we need to get the
    # volume to fermenter + losses.

    logger.debug "volume from brew_entry: #{brew_entry}"
    return brew_entry.volume_to_fermenter_and_system_loses
  end

  def self.search_condition
    logger.debug "recipe search_condition called"
    return $PRIMARY_RECIPE_FILTER
  end

  def is_brewday?
    return true unless brew_entry.nil?
  end

  def is_brewday_planning?

    logger.debug "++is_brewday_planning?"
    logger.debug "Recipe: #{self.id}"
    logger.debug "Brew entry: #{brew_entry}"

    return nil if brew_entry.nil?

    logger.debug "Brew entry id: #{brew_entry.id}"
    return brew_entry.is_planned?
  end


  def volume=( new_volume )

    old_volume = read_attribute(:volume)
    change_factor = 1.0 #Cater for recipe creation when volume is not already set
    change_factor = 0.0 + (old_volume/new_volume) if old_volume
    logger.debug "Change factor: #{change_factor}"

    # Change locked elements so that they are no effected by the new volume.
    adjust_weights( change_factor ) unless change_factor == 1.0
 
    # Save the new volume.

    write_attribute( :volume, new_volume)
    #save
    #reload
    
    #@volume = new_volume
  end

  def efficency= ( new_efficency )

    new_efficency = new_efficency.to_f
    old_efficency = read_attribute(:efficency).to_f

    change_factor = 1.0 #Cater for recipe creation when efficency is not already set
    change_factor = 0.0 + (new_efficency/old_efficency) if old_efficency
    logger.debug "Change factor: #{change_factor}"

    # Change locked elements so that they are no effected by the new volume.
    adjust_weights( change_factor, true ) unless change_factor == 1.0

    # Save the new volume.

    write_attribute( :efficency, new_efficency)
    #save
    #reload

    #@volume = new_volume
  end

  def adjust_weights( factor, hops_og_only = false )
    # Check for locked ferementables
    logger.debug "Checking for locked fermentables"

    old_og = self.og

    fermentables.each do |fermentable|
      next unless fermentable
      if fermentable.is_weight_locked? then
        logger.debug "Fermentable old points: #{fermentable.points}"
        fermentable.points = fermentable.points * factor
        fermentable.save
        logger.debug "Fermentable new points: #{fermentable.points}"
      end
    end

    # Check for locked hops
    logger.debug "Checking for locked hops"

    factor = 1.0 if hops_og_only
    adjust_fixed_hops_for_change( factor, self.og, old_og )


  end


  #  protected
  #  def pre_destroy
  #    #Remove brew_entries
  #
  #    brew_entries.each { |brew_entry|
  #      next unless brew_entry
  #      brew_entry.destroy
  #    }
  #
  #    #Remove other recipe artifacts
  #    fermentables.each { |fermentable|
  #      next unless fermentable
  #      fermentable.destroy
  #    }
  #
  #    hops.each { |hop|
  #      hop.destroy
  #    }
  #
  #    yeasts.each{ |yeast|
  #      next unless yeast
  #      yeast.destroy
  #    }
  #
  #
  #    mash_steps.each{ |mash_step|
  #      next unless mash_step
  #      mash_step.destroy
  #    }
  #
  #    misc_ingredients.each{ |misc|
  #      next unless misc
  #      misc.destroy
  #    }
  #  end

  def is_cubed?
    return false if hop_cubed.nil?
    return hop_cubed
  end

  def hop_cubed=( new_val )

    logger.debug "++hop_cubed"
    return if new_val.nil?
    return if new_val == self[:hop_cubed] #Nothing to do

    write_attribute(:hop_cubed, new_val)

    logger.debug "Adjusting hop values for cubing"
    #Reprocess to consider new values.
    hops.each { |hop|
      hop.adjust_for_cubing( new_val)
      hop.save
    }
  end

  def adjust_fixed_hops_for_change( factor, new_og, old_og )

    logger.debug "++ adjust_fixed_hops_for_change - new_og: #{new_og} old_og: #{old_og}"

    hops.each do |hop|
      next unless hop
      if hop.is_weight_locked? then
        logger.debug "Hop old ibu: #{hop.ibu_l}"

        # Need to adjust for change in fermentables as well.
        hop.adjust(factor, old_og, new_og)
        hop.save
        
        logger.debug "Hop new ibu: #{hop.ibu_l}"
      end
    end
  end

  def scale( new_volume, new_efficency )
    # Scaling is done automatically, so just need to bypass the weight adjustment checks
    logger.debug "++scale: new_volume-#{new_volume} new_efficency-#{new_efficency}"

    write_attribute( :efficency, new_efficency) if new_efficency and (new_efficency != "")
    write_attribute( :volume, new_volume) if new_volume and (new_volume != "")
    save
  end

  def name
    name = read_attribute( :name )

    return "" unless name  #Need to cater for the recipe creation scenario where the name is null.
    
    return name.empty? ? "<no name>" : name
  end

  def add_to_shared( user )

    #Dont add the owner to the shared list
    return if (user == self.user)

    #Ensure shared recipe record exists
    create_recipe_shared unless recipe_shared

    #Add new user if not already in the list.
    if not recipe_shared.recipe_user_shared.find_by_user_id( user.id )
      recipe_shared.recipe_user_shared.create( :user => user, :shared_state => :invited.to_s, :can_edit => true )
    end
    
  end

end
