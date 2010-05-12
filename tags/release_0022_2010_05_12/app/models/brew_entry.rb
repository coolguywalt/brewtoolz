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

class BrewEntry < ActiveRecord::Base

  hobo_model # Don't put anything above this

  include RecipeCalcs

  fields do
    brew_date :date
    comment :text
    actual_fg :float
    bottled_kegged :date
    actual_og :float
    volume_to_ferementer :float
    pitching_temp :float
    actual_colour :float
    rating :float
    absorbtion_rate :float
    mash_conversion :float
    volume_from_mash :float
    volume_to_boil :float
    mash_dead_space :float

    ambient_temp :float

    actual_extract_volume :float   #boil volume
    actual_extract_sg :float	#boil gravity

    liquor_to_grist :float

    boiler_loses :float
    evaporation_rate :float

    boil_time :integer
    #
    sparge_method enum_string(:batch, :fly, :none)
    #
    no_batches :integer
    #
    batch1_volume :float
    batch1_gravity_actual :float
    batch1_volume_actual :float
    #
    batch2_volume :float
    batch2_gravity_actual :float
    batch2_volume_actual :float
    #
    batch3_volume :float
    batch3_gravity_actual :float
    batch3_volume_actual :float
    #
    batch4_volume :float
    batch4_gravity_actual :float
    batch4_volume_actual :float
    #
    preboil_gravity_actual :float
    preboil_volume_actual :float
    #
    postboil_gravity_actual :float
    postboil_volume_actual :float

    timestamps
  end

  belongs_to :recipe
  belongs_to :user, :creator => true
  belongs_to :brewery  # Possibly a bit strong of an inference but is the rails way of referring to another table.

  has_many :brew_entry_logs, :dependent => :destroy
  has_one :actual_recipe, :class_name => 'Recipe', :dependent => :destroy #used to cache copy of actual recipe brewed.


   # before_destroy :pre_destroy

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    logger.debug "Acting user: #{acting_user}"
    # return false unless acting_user
    user_is? acting_user || acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

  def before_destroy
    self.actual_recipe.destroy if self.actual_recipe  #Ensure brew entry recipe is also destroyed.
  end
  
  def max_rating
    max_rating_value = 0
    brew_entry_logs.each do |brew_entry_log|
      if brew_entry_log.istasting then
        max_rating_value = brew_entry_log.rating if brew_entry_log.rating > max_rating_value
      end
    end

    return max_rating_value
  end

  def ave_rating

    logger.debug "average rating called"
    rating_total = 0.0
    rating_count = 0
    brew_entry_logs.each do |brew_entry_log|
      if brew_entry_log.istasting then
        rating_total += brew_entry_log.rating
        rating_count += 1
      end
    end

    return rating_total/rating_count if rating_count > 0
    return -1.0 # signifies a non valid entry
  end

  def recalc_rating
    #return 0.0 if brew_entry_logs.count == 0

    new_rating = ave_rating
    logger.debug( "New rating: #{new_rating}" )

    @rating = new_rating
    update_attribute(:rating, new_rating)

    logger.debug( "New rating: #{@rating}" )

    recipe.recalc_rating if recipe
  end


  def actual_bugu_ratio
    return recipe.ibu/actual_og
  end

  def actual_balance
    return calc_balance(actual_og, fg, recipe.ibu)
  end

  def actual_abv
    return calc_abv( actual_og, fg )
  end

  def actual_attenuation
    return calc_attenuation(actual_og, fg)
  end

  def attenuation
    # returns attenuation as calculated by the last observation if not FG has been entered.
    return calc_attenuation(actual_og, actual_fg) if actual_fg && (actual_fg > 0)

    # no actual og, find the MIN observation gravity value
    min_observed_og_log =
      brew_entry_logs.find(:first,
      :order => "specific_gravity",
      :conditions => "(specific_gravity > 0) and (log_type ='observation')")

    logger.debug("Looking for a brew_entry_log")

    return 0 unless min_observed_og_log  # no records found.

    # found a log entry
    return calc_attenuation(actual_og, min_observed_og_log.specific_gravity)

  end

  def actual_rte
    return calc_rte(actual_og, actual_fg)
  end

  def actual_efficency
    recipe.efficency * ((recipe.og * recipe.volume)/(actual_og * the_volume_to_ferementer))
  end

  def status

    now = DateTime.now

    return nil unless brew_date
    return :Planned if brew_date > now
    return :Conditioning if bottled_kegged && (est_ready > now && bottled_kegged < now)
    return :Ready if isReady
    return :Fermenting if brew_date <= now
    return :Unknown
  end

  def est_ready
    # Will eventually add in time to consider longer ferment for lagers etc
    return nil unless brew_date
    return bottled_kegged.advance(:weeks => 2) if bottled_kegged
    return brew_date.advance(:weeks => 4)
  end

  def isReady
    #Precondition
    return false unless brew_date

    return est_ready <= DateTime.now
  end

  def rating
    recalc_rating if !@rating # if null then do a recalc to intialise the rating.
    return @rating
  end

  def yeast_pitching_rate

    modifier = 1.0

    if( actual_recipe ) then
      yeast_type = nil


      yeast_type = recipe.yeasts[0].yeast_type.name if recipe.yeasts.count > 0

      #Determine is strain is a lager strain.
      #logger.debug "Strain: #{recipe.yeasts[0].yeast_type.name}"
      if( yeast_type ) then
        modifier = 2.0 if (yeast_type.downcase =~ /lager/)   # lager beers
        modifier = 1.5 if (yeast_type.downcase =~ /k.lsch/)  # kolsch
      end
    end


    # Calc for ale pitching rates
    yeast_cells = pitching_rate(og, the_volume_to_ferementer) * modifier

    #logger.debug "Yeast cells: #{yeast_cells}, is_lager: #{is_lager}"

    return yeast_cells
  end

  def copy_to_actual_recipe( a_recipe, brewery, new_user )
    return unless a_recipe #protect against nill parameter

    #Create actual recipe
    #begin
      new_actual_recipe = a_recipe.deep_clone
    #rescue
    #  logger.debug "Problem deepcloning recipe: #{a_recipe.name}"
    #end

    logger.debug "New recipe: #{new_actual_recipe.id}"

    #Problem with new recipe object, reload from database
    new_recipe = Recipe.find( new_actual_recipe.id )

    logger.debug "Updating reference to brew_entry"
    new_recipe.brew_entry = self
    new_recipe.save()

    logger.debug "Updating brewery and efficiency"
    efficency = brewery ? brewery.efficency : 75.0
    new_recipe.efficency = efficency
    new_recipe.user = new_user
    new_recipe.save()

  end

  def og

    the_og = 50.0 # default to 50 points if no other information if provided.

    if( actual_og ) then
      the_og = actual_og
    elsif( actual_recipe ) then
      the_og = actual_recipe.og
    elsif( recipe ) then
      the_og = recipe.og
    end
    return the_og
  end

  def min_log_sg
    #return last gravity reading if recorded
    minlog = brew_entry_logs.minimum :specific_gravity, :conditions => "(specific_gravity is not null) and (specific_gravity > 0.0)"
    return minlog
  end

  def fg
    #return actual value if recorded
    return actual_fg if( actual_fg )

    #return last gravity reading if recorded
    minlog = min_log_sg
    return minlog if minlog

    return actual_recipe.fg if actual_recipe

    return recipe.fg if recipe

    return  50.0 * 0.75
  end

  def therecipe
    return actual_recipe if actual_recipe
    return recipe if recipe
    return nil
  end

  def the_liquor_to_grist_ratio
    return liquor_to_grist if liquor_to_grist
    return 3.0 # default to 3, units 1/kg
  end

  def mash_water
    # Return mash water in liters
    return nil unless therecipe
    mashwater = therecipe.total_mash_weight * the_liquor_to_grist_ratio / 1000.0
    return mashwater
  end

  def preboilvolume

    # roughly equal to volume to ferementer + mashing loss + system loss + evaporation loss
    preboil = the_volume_to_ferementer + system_loss + evapouration_loss

    return preboil
  end

  def volume_to_fermenter_and_system_loses
    # 2- is the mash tun loss
    # 4- is the trub etc loss from the boiler to the ferementer
    #TODO 5 - hop absorbtion .. not added yet
    return the_volume_to_ferementer + system_loss + mash_loss

  end

  def evapouration_loss
    loss_per_hr = evaporation_rate || 4.0
    loss_per_hr = 4.0 unless loss_per_hr # protect against nill value stored in brewery.

    return loss_per_hr * boil_time / 60.0
  end

  def mash_loss

    # Need to take into account the evapouration rate in the mash tun lose.

    loss = mash_dead_space || (thebrewery.mash_tun_deadspace || 2.0)
    loss = 2.0 unless loss # protect against nill value stored in brewery.

    percentage_post_boil = (preboilvolume - evapouration_loss)/ preboilvolume

    effective_mash_lose = loss * percentage_post_boil

    return effective_mash_lose
  end

  def system_loss
    boil_to_fermenter_loss = boiler_loses || thebrewery.boiler_loses
    boil_to_fermenter_loss = 4.0 unless boil_to_fermenter_loss # protect against nill value stored in brewery.

    #loss = mash_loss + boil_to_fermenter_loss
    loss = boil_to_fermenter_loss
    return loss
  end

  def total_loss
    evapouration_loss + system_loss + mash_loss
  end

  def total_effective_volume
    # Required in calculations for volume adjustments when attempting to keep weights constants.
    return nil unless volume_to_ferementer
    

    volume_to_ferementer + system_loss + mash_loss
    
  end

  def boil_time
    local_boiltime = read_attribute(:boil_time)
    return local_boiltime if local_boiltime
    return thebrewery.boil_time if thebrewery && thebrewery.boil_time
    return 60 # default to 60 minutes
  end

  def thebrewery
    #logger.debug "Current brewery: #{brewery.name}"
    return brewery || Brewery.default_brewery(self.user)
  end

  def mash_tun_volume
    return mash_tun_volume = mash_water + therecipe.total_mash_weight/1000.0 * $GRAIN_DISPLACEMENT + first_sparge_top_up
  end

  def first_sparge_top_up
    top_up = per_sparge_volume - (mash_water - mash_loss - ($GRAIN_ABSORBTION * therecipe.total_mash_weight/1000.0))
    top_up = 0.0 if top_up < 0.0 # cannot be a negative number
    return top_up
  end

  def per_sparge_volume
    #assume 2 sparges for the moment.
    return preboilvolume / the_no_batches
  end

  def sparge1_water_addition
    return first_sparge_top_up
  end

  def sparge1_volume
    return per_sparge_volume if first_sparge_top_up > 0.0
    return mash_water - mash_loss - $GRAIN_ABSORBTION * therecipe.total_mash_weight/1000.0
  end

  def sparge1_gravity
    points_recovered = (max_mash_points * volume_to_fermenter_and_system_loses) * sparge1_volume / (mash_water + first_sparge_top_up)

    logger.debug "points recovered: #{points_recovered}"


    gravity = points_recovered/sparge1_volume
    return gravity
  end

  def sparge1_required_gravity
    points_recovered = (max_mash_points*(preboilrequiredgravity/preboilgravity) * volume_to_fermenter_and_system_loses) * sparge1_volume / (mash_water + first_sparge_top_up)

    logger.debug "points recovered: #{points_recovered}"


    gravity = points_recovered/sparge1_volume
    return gravity
  end

  def sparge2_water_addition
    return 0.0 if the_no_batches < 2
    return per_sparge_volume * 2 - sparge1_volume
  end

  def sparge2_volume

    return sparge2_water_addition
  end

  def sparge2_gravity
    return 0.0 if the_no_batches < 2
    points_left_in_mash = (max_mash_points * volume_to_fermenter_and_system_loses) - (sparge1_gravity * sparge1_volume)
    points_recovered = points_left_in_mash * sparge2_volume / ( mash_water + first_sparge_top_up - sparge1_volume + sparge2_volume )

    return points_recovered / sparge2_volume
  end

  def sparge2_required_gravity
    return 0.0 if the_no_batches < 2
    points_left_in_mash = (max_mash_points*(preboilrequiredgravity/preboilgravity) * volume_to_fermenter_and_system_loses) - (sparge1_required_gravity * sparge1_volume)
    points_recovered = points_left_in_mash * sparge2_volume / ( mash_water + first_sparge_top_up - sparge1_volume + sparge2_volume )

    return points_recovered / sparge2_volume
  end

  def sparge3_water_addition
    return 0.0 if the_no_batches < 3
    return per_sparge_volume * 3 - sparge1_volume - sparge2_volume
  end

  def sparge3_volume
    return sparge3_water_addition
  end

  def sparge3_gravity
    return 0.0 if the_no_batches < 3
    points_left_in_mash = (max_mash_points * volume_to_fermenter_and_system_loses) - (sparge1_gravity * sparge1_volume) - (sparge2_gravity * sparge2_volume)
    points_recovered = points_left_in_mash * sparge3_volume / ( mash_water + first_sparge_top_up - sparge1_volume + sparge3_volume )

    return points_recovered / sparge3_volume
  end

  def sparge3_required_gravity
    return 0.0 if the_no_batches < 3
    points_left_in_mash = (max_mash_points*(preboilrequiredgravity/preboilgravity) * volume_to_fermenter_and_system_loses) - (sparge1_required_gravity * sparge1_volume) - (sparge2_required_gravity * sparge2_volume)
    points_recovered = points_left_in_mash * sparge3_volume / ( mash_water + first_sparge_top_up - sparge1_volume + sparge3_volume )

    return points_recovered / sparge3_volume
  end

  def sparge4_water_addition
    logger.debug "sparge4_water_addition"

    return 0.0 if the_no_batches < 4
    return per_sparge_volume * 4 - sparge1_volume - sparge2_volume - sparge3_volume
  end

  def sparge4_volume
    logger.debug "sparge4_volume"
    return sparge4_water_addition
  end

  def sparge4_gravity
    logger.debug "sparge4_gravity"
    return 0.0 if the_no_batches < 4
    points_left_in_mash = (max_mash_points * volume_to_fermenter_and_system_loses) - (sparge1_gravity * sparge1_volume) - (sparge2_gravity * sparge2_volume) - (sparge3_gravity * sparge3_volume)
    points_recovered = points_left_in_mash * sparge4_volume / ( mash_water + first_sparge_top_up - sparge1_volume + sparge4_volume )
    logger.debug "sparge4_gravity end"
    return points_recovered / sparge4_volume
  end

  def sparge4_required_gravity

    return 1.0

    logger.debug "sparge4_required_gravity"
    return 0.0 if the_no_batches < 4
    points_left_in_mash = (max_mash_points*(preboilrequiredgravity/preboilgravity) * volume_to_fermenter_and_system_loses) - (sparge1_gravity * sparge1_volume) - (sparge2_gravity * sparge2_volume) - (sparge3_gravity * sparge3_volume)
    points_recovered = points_left_in_mash * sparge4_volume / ( mash_water + first_sparge_top_up - sparge1_volume + sparge4_volume )

    logger.debug "sparge4_required_gravity end"
    return points_recovered / sparge4_volume



  end


  def mash_conversion
    mc = read_attribute(:mash_conversion)

    begin
      mc_f = Float(mc)
    rescue
      mc_f = 100.0
    end

    logger.debug "Mash conversion: #{mc_f}"
   
    return mc_f
  end


  def no_batches
    nb = read_attribute(:no_batches)
    nb= 2 unless nb #Check for null value.

    logger.debug "No batches: #{nb}"

    return nb
  end

  def ambient_temp
    read_attribute(:ambient_temp) || 21.0
  end

  def max_mash_points
    max_points = therecipe.total_mash_points * (mash_conversion/100.0) / (
      therecipe.efficency/100.0)

    logger.debug "max mash points: #{max_points}"

    return max_points
  end

  def mash_gravity
    max_mash_points * mash_water / volume_to_fermenter_and_system_loses
  end


  def preboilgravity
    gravity = (sparge1_gravity*sparge1_volume + sparge2_gravity*sparge2_volume + sparge3_gravity*sparge3_volume + sparge4_gravity*sparge4_volume) / preboilvolume
  end

  def preboilefficiency
    (preboilgravity * preboilvolume) / (max_mash_points/(mash_conversion/100) * volume_to_fermenter_and_system_loses)
  end

  def brewhouse_efficency
	  actual_og / max_mash_points
  end

  def preboilrequiredgravity
    required_gravity = therecipe.total_mash_points * volume_to_fermenter_and_system_loses / ( volume_to_fermenter_and_system_loses + evapouration_loss )
    return required_gravity
  end

  def total_spargewater
    sparge1_water_addition + sparge2_water_addition + sparge3_water_addition + sparge4_water_addition
  end

  def the_no_batches
    return no_batches if no_batches
    return 2
  end

  def the_volume_to_ferementer
    return volume_to_ferementer if volume_to_ferementer
    return 23.0
  end

  def google_graph_sg_url

    #http://chart.apis.google.com/chart?cht=lxy&chd=t:1,2,3,50,51|60,40,98,36,7&chs=250x100&chxt=x,y&chxr=0,0,55&chm=r,ffff99,0,0.1,0.7&chds=0,55
    #
    #
    #http://chart.apis.google.com/chart?
    #cht=lxy&     << Chart type xy data
    #chd=t:1,2,3,50,51|60,40,98,36,7&   << Data for x and y
    #chs=250x100&  << size of image produced
    #chxt=x,y&  << axis labeling
    #chxr=0,0,55&  << range of x-axis displayed
    #chds=0,55& << actually range of axis (first two values x, then y ) -- very important with above option, otherwise is considered to be 1-100
    #chm=r,ffff99,0,0.1,0.7&  << range that is highlighted in background, r=vertical R=horizontal

    #<img src="http://chart.apis.google.com/chart?
    #chs=250x100
    #&amp;chd=t:60,40
    #&amp;cht=p3
    #&amp;chl=Hello|World"
    #alt="Sample chart" />

    chart_str =  "http://chart.apis.google.com/chart?chs=600x100&amp;cht=lxy&amp;chxt=x,y"

    # First data point - the brew day
    xdata_str = "0"
    ydata_str = "" + actual_og.to_s

    ymax = actual_og
    xmax = 0

    brew_entry_logs.find(:all,
      :order => "log_date",
      :conditions => "(specific_gravity > 0) and (log_type ='observation')").each do |entry|

      logger.debug("Entry log date: #{entry.log_date}, Brew date: #{brew_date}")

      next unless entry.specific_gravity and entry.log_date

      log_date = entry.log_date.to_date
      date_distance = (log_date - brew_date).to_i
      xmax = date_distance
      xdata_str += "," + date_distance.to_s
      ydata_str += "," + entry.specific_gravity.to_s
    end

    if( bottled_kegged && actual_fg ) then
      # last data point, the bottled/keg day.
      last_date_distance = (bottled_kegged - brew_date).to_i
      xmax = last_date_distance
      xdata_str += "," + last_date_distance.to_s
      ydata_str += "," + actual_fg.to_s
    end

    data_str = "chd=t:" + xdata_str +"|" + ydata_str
    logger.debug "data_str: #{data_str}"

    chart_str += "&amp;" + data_str

    # Add range data
    chart_str += "&amp;chxr=0,0," + (xmax+1).to_s + ",1|1,0,"  + (ymax+5).to_s +
      "&amp;chds=0," + (xmax+1).to_s + ",0," + (ymax+5).to_s

    # Add target FG data line
    target_fg_per = therecipe.fg/(ymax+5)
    target_og_per = actual_og/(ymax+5)

    chart_str += "&amp;chm=r,dddddd,0," + target_fg_per.to_s + "," + target_og_per.to_s


    return chart_str
  end
 
  def is_fermenting?
    return true unless bottled_kegged  # Check for nil bottled kegged date and default to fermenting
    return (bottled_kegged > DateTime.now)
  end

  def is_planned?
    logger.debug "Status: #{status}"
    return (status == :Planned)
  end

  def setbrewery( new_brewery )
    logger.debug "Setting brewery to: #{new_brewery}"

    return unless new_brewery.is_a?(Brewery)

    logger.debug "Updating brewery attributes"

	  self.brewery = new_brewery

    self.volume_to_ferementer = new_brewery.capacity
    self.mash_dead_space = new_brewery.mash_tun_deadspace
    self.boil_time = new_brewery.boil_time
    self.evaporation_rate = new_brewery.evapouration_rate
    self.boiler_loses = new_brewery.boiler_loses
    self.liquor_to_grist = new_brewery.liquor_to_grist

    actual_recipe.write_attribute(:efficency, new_brewery.efficency) if (actual_recipe && new_brewery.efficency)
  end

  def mash_grain_weight
    therecipe.total_mash_weight
  end

  def mash_schedule
    #list of mash to process:
    list = MashStep.find_all_by_recipe_id(actual_recipe.id, :order => 'temperature, name')

    #Handle case where no mashing schedule is defined
    return [MashStep.default] if list.size == 0

    volume = mash_water

    #Process the list starting with the last entry working backwards.
    index = list.length-1

    while index > 0 do
      #Work out temp differential and target volume differential, aim for 90C water except for mash-in
      case list[index].steptype
      when "infusion"
        step_volume = calc_volume_for_temp( list[index-1].temperature, list[index].temperature, 95.0, volume, (mash_grain_weight/1000.0) )
        list[index].addition_amount = step_volume
        list[index].addition_temp = 95.0
     
        list[index].liquor_to_grist = volume/(mash_grain_weight/1000.0)
        list[index].save

        volume = volume - step_volume

      when "decoction"
        #Work out required decoction step
        step_amount = calc_volume_for_decoction( list[index-1].temperature, list[index].temperature, volume, (mash_grain_weight/1000.0) )
        list[index].addition_amount = step_amount
        list[index].addition_temp = 100.0

        list[index].liquor_to_grist = volume/(mash_grain_weight/1000.0)
        list[index].save
      end

      index = index - 1
      
    end

    #Special case for mash-in step if not direct heat
    if list[0].steptype == :infusion then
      if mash_grain_weight == 0.0 then  #Would almost never happen, but is a case that needs to be considered.
        list[0].liquor_to_grist = 0.0
        list[0].addition_temp = 0.0
      else
        list[0].addition_amount = volume
        list[0].liquor_to_grist = volume/(mash_grain_weight/1000.0)
        step_temp = calc_temp_for_volume( ambient_temp, list[0].temperature, list[0].liquor_to_grist )
        list[0].addition_temp = step_temp
      end
      list[0].save
    end


    return list
  end


  def calc_volume_for_temp( t1, t2, tw, wt, g )
    #t1 - initial mash temp
    #t2 - target mash temp
    #tw - temp of water addition
    #g - amount of grain in mash (kg)
    #wt - total amount of water after addition

    dTc = (t2-t1)/(tw-t2)
    wa = dTc*(0.41*(g/1000.0) + wt) / (1 + dTc)
    return wa
  end

  def calc_temp_for_volume( t1, t2, r )
    #t1 - initial temp
    #t2 - target temp
    #r  - liquor to grist ratio

    ta = (0.41/r)*(t2-t1) + t2
    return ta
  
  end

  def calc_volume_for_decoction( t1, t2, w, grain_weight )
    rd = 2.0864 # Assumes decoction in reasonably thick at 2.08 ltrs/kg
    gd = (1/rd+0.667)
    wd = gd*rd

    vd = ((t2-t1)*(0.4*grain_weight + 2*w))/((100-t1)*(0.4*gd + wd))
    
    return vd * 0.946352946    # Convert from quarts to litres
  end

#  def volume_to_fermenter
#    vtf = read_attribute( :volume_to_fermenter)
#    return vtf || 23.0  # Return a default value to allow fo
#  end


  def volume_to_ferementer= (new_volume)

    new_volume = new_volume.to_f
    logger.debug "New volume: #{new_volume}"

    old_total_volume = total_effective_volume
    logger.debug "Old total volume: #{old_total_volume}"

    # Save the new volume.
    write_attribute( :volume_to_ferementer, new_volume)
    save
    reload
    
    new_total_volume = total_effective_volume
    logger.debug "New total volume: #{new_total_volume}"

    return if old_total_volume.nil?  #Initialisation state, no need to adjust for volume changes.

    #change_factor = 0.0
    change_factor = old_total_volume/new_total_volume
    logger.debug "Change factor: #{change_factor}"

    # Change locked elements so that they are no effected by the new volume.
    arecipe = therecipe
    arecipe.adjust_weights( change_factor ) if arecipe

  end

#  protected
#
#  def pre_destroy
#
#  end
end
