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
    include UnitsHelper

    fields do
        brew_date :date
        comment :text
        actual_fg :float
        bottled_kegged :date
        yeast_pitched_date :date
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

        same_water :boolean
        dilution_rate_mash :integer
        dilution_rate_sparge :integer
        calcium_chloride_mash :float
        gypsum_mash :float
        epsom_salt_mash :float
        table_salt_mash :float
        baking_soda_mash :float
        chalk_mash :float
        calcium_chloride_sparge :float
        gypsum_sparge :float
        epsom_salt_sparge :float
        table_salt_sparge :float
        baking_soda_sparge :float
        chalk_sparge :float

        citric_volume_mash :float
        citric_strength_mash :integer
        lactic_volume_mash :float
        lactic_strength_mash :integer
        phosphoric_volume_mash :float
        phosphoric_strength_mash :integer
        citric_volume_sparge :float
        citric_strength_sparge :integer
        lactic_volume_sparge :float
        lactic_strength_sparge :integer
        phosphoric_volume_sparge :float
        phosphoric_strength_sparge :integer

        timestamps
    end

    validates_numericality_of :volume_to_ferementer, :greater_than_or_equal_to => 0
    validates_numericality_of :dilution_rate_mash, :greater_than_or_equal_to => 0,
        :less_than_or_equal_to => 100
    validates_numericality_of :dilution_rate_sparge,
        :greater_than_or_equal_to => 0,
        :less_than_or_equal_to => 100
    validates_numericality_of :calcium_chloride_mash,
        :greater_than_or_equal_to => 0.0
    validates_numericality_of :gypsum_mash, :greater_than_or_equal_to => 0.0
    validates_numericality_of :epsom_salt_mash, :greater_than_or_equal_to => 0.0
    validates_numericality_of :table_salt_mash, :greater_than_or_equal_to => 0.0
    validates_numericality_of :baking_soda_mash, :greater_than_or_equal_to => 0.0
    validates_numericality_of :chalk_mash, :greater_than_or_equal_to => 0.0
    validates_numericality_of :calcium_chloride_sparge,
        :greater_than_or_equal_to => 0.0
    validates_numericality_of :gypsum_sparge, :greater_than_or_equal_to => 0.0
    validates_numericality_of :epsom_salt_sparge, :greater_than_or_equal_to => 0.0
    validates_numericality_of :table_salt_sparge, :greater_than_or_equal_to => 0.0
    validates_numericality_of :baking_soda_sparge,
        :greater_than_or_equal_to => 0.0
    validates_numericality_of :chalk_sparge, :greater_than_or_equal_to => 0.0
    validates_numericality_of :citric_volume_mash,
        :greater_than_or_equal_to => 0.0
    validates_numericality_of :citric_strength_mash, :greater_than => 0,
        :less_than_or_equal_to => 100
    validates_numericality_of :lactic_volume_mash,
        :greater_than_or_equal_to => 0.0
    validates_numericality_of :lactic_strength_mash, :greater_than => 0,
        :less_than_or_equal_to => 100
    validates_numericality_of :phosphoric_volume_mash,
        :greater_than_or_equal_to => 0.0
    validates_numericality_of :phosphoric_strength_mash, :greater_than => 0,
        :less_than_or_equal_to => 100
    validates_numericality_of :citric_volume_sparge,
        :greater_than_or_equal_to => 0.0
    validates_numericality_of :citric_strength_sparge, :greater_than => 0,
        :less_than_or_equal_to => 100
    validates_numericality_of :lactic_volume_sparge,
        :greater_than_or_equal_to => 0.0
    validates_numericality_of :lactic_strength_sparge, :greater_than => 0,
        :less_than_or_equal_to => 100
    validates_numericality_of :phosphoric_volume_sparge,
        :greater_than_or_equal_to => 0.0
    validates_numericality_of :phosphoric_strength_sparge, :greater_than => 0,
        :less_than_or_equal_to => 100

    belongs_to :recipe
    belongs_to :user, :creator => true
    belongs_to :brewery  # Possibly a bit strong of an inference but is the rails way of referring to another table.

    has_many :brew_entry_logs, :dependent => :destroy
    has_one :actual_recipe, :class_name => 'Recipe', :dependent => :destroy #used to cache copy of actual recipe brewed.

    @@acids = {
        :citric => {
        :molar_mass         => 210.14 ,
        :reference_density  =>   1.50 ,
        :reference_strength => 100
    },
        :lactic => {
        :molar_mass         =>  90.0  ,
        :reference_density  =>   1.20 ,
        :reference_strength =>  88
    },
        :phosphoric => {
        :molar_mass         =>  98.0  ,
        :reference_density  =>   1.08 ,
        :reference_strength =>  10
    }
    }
    def self.acids
        @@acids
    end

    @@salts = {
        :gypsum           => { :formula => 'CaSO&#8324;' },
        :epsom_salt       => { :formula => 'MgSO&#8324;' },
        :calcium_chloride => { :formula => 'CaCl&#8322;' },
        :table_salt       => { :formula => 'NaCl' },
        :baking_soda      => { :formula => 'NaHCO&#8323;' },
        :chalk            => { :formula => 'CaCO&#8323;' }
    }
    def self.salts
        @@salts
    end

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

    def after_initialize
        self.same_water = true if self.same_water.nil?
        [:mash, :sparge].each do |phase|
            if self.send("dilution_rate_#{phase}").nil?
                self.send( "dilution_rate_#{phase}=", 0 )
            end
            @@salts.keys.each do |salt|
                if self.send("#{salt}_#{phase}").nil?
                    self.send( "#{salt}_#{phase}=", 0.0 )
                end
            end
            @@acids.keys.each do |acid|
                if self.send("#{acid}_volume_#{phase}").nil?
                    self.send( "#{acid}_volume_#{phase}=", 0.0 )
                end
                if self.send("#{acid}_strength_#{phase}").nil?
                    self.send( "#{acid}_strength_#{phase}=",
                              @@acids[acid][:reference_strength] )
                end
            end
        end
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
        return yeast_pitched_date.advance(:weeks => 2) if yeast_pitched_date
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

    def postboilvolume
        # roughly equal to volume to ferementer +  system loss
        postboil = the_volume_to_ferementer + system_loss

        return postboil
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

        # logger.debug "No batches: #{nb}"
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
        totspargewater = sparge1_water_addition + sparge2_water_addition + sparge3_water_addition + sparge4_water_addition
        return totspargewater.to_f
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

        ferment_start = brew_date
        ferment_start = yeast_pitched_date if yeast_pitched_date

        brew_entry_logs.find(:all,
                             :order => "log_date",
                             :conditions => "(specific_gravity > 0) and (log_type ='observation')").each do |entry|

            logger.debug("Entry log date: #{entry.log_date}, Brew date: #{brew_date}")

            next unless entry.specific_gravity and entry.log_date

            log_date = entry.log_date.to_date
            date_distance = (log_date - ferment_start ).to_i
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

    def volume_to_ferementer= (new_volume)

        new_volume = new_volume.to_f
        logger.debug "New volume: #{new_volume}"

        old_total_volume = total_effective_volume
        logger.debug "Old total volume: #{old_total_volume}"

        # Save the new volume.
        write_attribute( :volume_to_ferementer, new_volume)
        return unless save #Dont bother processing further is save fails.
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


  def dilution_factor(phase)
    @_factor ||= {}
    if !@_factor.has_key?(phase)
      @_factor[phase] = send("dilution_rate_#{phase}") / 100.0
    end
    return @_factor[phase]
  end

  def ro_water( volume, phase )
    return 0 unless volume # protects against nil volume being passed in.
    return volume * dilution_factor(phase)
  end

  def tap_water( volume, phase )
    return 0 unless volume # protects against nil volume being passed in.
    return volume * ( 1.0 - dilution_factor(phase) )
  end

  def diluted(ion, phase)
    factor = dilution_factor(phase)
    ro_brewery = Brewery.ro_brewery
    return factor * ro_brewery.send(ion) +
      ( 1.0 - factor ) * ( thebrewery.send(ion) || ro_brewery.send(ion) )
  end

  def alkalinity(phase)
    return adjusted(:total_alkalinity, phase) ||
           adjusted(:bicarbonate, phase) * 50.0 / 61.0 +
             adjusted(:carbonate, phase) * 100.0 / 60.0
  end

  def residual_alkalinity(phase)
    return alkalinity(phase) - adjusted(:calcium, phase) / 1.4 -
           adjusted(:magnesium, phase) / 1.7
  end

  def buffer_capacity
    return 35.0                 # mEq / ( pH * kg )
  end

  def acid_density(acid, strength)
    return strength / @@acids[acid][:reference_strength] *
           ( @@acids[acid][:reference_density] - 1.0 ) + 1.0 # kg/l
  end

  def acid_solution_mass(acid, volume, strength)
    volume * acid_density(acid, strength) # g
  end

  def acid_mass(acid, volume, strength)
    return ( strength / 100.0 ) *
           acid_solution_mass(acid, volume, strength) # g
  end

  def acid_power(acid, volume, strength)
    return 1000.0 * acid_mass(acid, volume, strength) /
           @@acids[acid][:molar_mass] # mEq
  end

  def _mash_volume
    if !defined?(@_mash_volume)
      @_mash_volume = mash_water
    end
    return @_mash_volume
  end

  def _sparge_volume
    if !defined?(@_sparge_volume)
      @_sparge_volume = total_spargewater
    end
    return @_sparge_volume
  end

  def alkalinity_change_from_acids(phase)
    return @@acids.keys.inject(0) do |total_alkalinity_change, acid|
      total_alkalinity_change +
        acid_power( acid, send( "#{acid}_volume_#{phase}" ) *
                          ( phase == :mash ? _mash_volume : _sparge_volume ),
                    send( "#{acid}_strength_#{phase}" ) )
    end
  end

  def estimated_mash_pH
    return therecipe.total_grist_pH(actual_og) +
           pH_change_from_residual_alkalinity + pH_change_from_acids

  end

  def pH_change_from_residual_alkalinity
    return residual_alkalinity(:mash) * the_liquor_to_grist_ratio /
           buffer_capacity / 50.0
  end

  def pH_change_from_acids
    return - alkalinity_change_from_acids(:mash) / buffer_capacity /
             ( mash_grain_weight / 1000.0 )
  end

  @@concentrations = {
    :bicarbonate => { :baking_soda => 191.0 },
    :calcium => { :calcium_chloride => 72.0, :chalk => 105.0, :gypsum => 61.5 },
    :carbonate => { :chalk => 158.0 },
    :chloride => { :calcium_chloride => 127.0, :table_salt => 160.3 },
    :magnesium => { :epsom_salt => 26.0 },
    :sodium => { :baking_soda => 75.0, :table_salt => 103.9 },
    :sulfate => { :epsom_salt => 103.0, :gypsum => 147.4 },
    :total_alkalinity => { :baking_soda => 156.6 }
  }

  @@water_ranges = {
    :bicarbonate => {
      :lo => 0.0,
      :hi => 250.0
    },
    :calcium => {
      :lo => 50.0,
      :hi => 150.0
    },
    :chloride => {
      :lo => 0.0,
      :hi => 250.0
    },
    :magnesium => {
      :lo => 10.0,
      :hi => 30.0
    },
    :sodium => {
      :lo => 0.0,
      :hi => 150.0
    },
    :sulfate => {
      :lo => 0.0,
      :hi => 350.0
    },
    :pH => {
      :lo => 5.2,
      :hi => 5.6
    }
  }

  def salt_contributions(ion, phase)
    return 0.0 unless @@concentrations[ion]
    return @@concentrations[ion].keys.inject(0) do |total_mass, salt|
      total_mass + send("#{salt}_#{phase}") /
                   ( phase == :mash ? _mash_volume : _sparge_volume ) *
                   @@concentrations[ion][salt] * 3.785
    end
  end

  def adjusted(ion, phase)
    return diluted(ion, phase) + salt_contributions(ion, phase)
  end

  def concentration_units(user)
    return wateradditions_weight_units(user) + "/" + volume_units(user)
  end

  def sulfate_chloride_ratio(phase)
    @_ratio ||= {}
    if !@_ratio.has_key?(phase)
      @_ratio[phase] = adjusted( :sulfate, phase ) /
                       adjusted( :chloride, phase )
    end
    return @_ratio[phase]
  end

  def sulfate_chloride_effect(phase)
    case sulfate_chloride_ratio(phase)
    when 0 ... 0.4
      return 'too malty'
    when 0.4 ... 0.6
      return 'very malty'
    when 0.6 ... 0.8
      return 'malty'
    when 0.8 ... 1.5
      return 'balanced'
    when 1.5 ... 2.0
      return 'slightly bitter'
    when 2.0 ... 4.0
      return 'bitter'
    when 4.0 ... 6.0
      return 'very bitter'
    when 6.0 ... 8.0
      return 'very very bitter'
    when 8.0 ... 9.0
      return 'very very very bitter'
    end
    return 'too bitter'
  end

  def level( quantity, value )
    if @@water_ranges.has_key?(quantity)
      if value < @@water_ranges[quantity][:lo]
        return "low"
      elsif value > @@water_ranges[quantity][:hi]
        return "high"
      end
    end
    return "ok"
  end

  def ion_level( ion, phase )
    return level( ion, adjusted( ion, phase ) )
  end

  def pH_level
    return level( :pH, estimated_mash_pH )
  end

#  protected
#
#  def pre_destroy
#
#  end
end
