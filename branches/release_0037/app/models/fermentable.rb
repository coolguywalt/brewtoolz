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

class Fermentable < ActiveRecord::Base

    hobo_model # Don't put anything above this

    include ApplicationModelsHelper

    fields do
        points :float  # gravity points per liter
        lock_weight :boolean
        timestamps
    end

    belongs_to :recipe
    belongs_to :fermentable_type

    has_many :fermentable_inventory_log_entries


    def log_entries
        return self.fermentable_inventory_log_entries
    end
    validates_numericality_of :points , :greater_than => 0.0, :message => "Gravity or weight must be a number > 0"
    # validates_numericality_of :percentage_points, :percentage_weight, :greater_than => 0.0, :less_than_equal_to => 100.0
    
    named_scope :list, :include => :fermentable_type, :order => "fermentable_types.name"

    @fermentable_array = []

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

    # -- accessors for point field.
    def weight=(new_weight_str)
        # don't update if it is already the same value.
        if( new_weight_str == weight ) then return end

        # error checking and feedback.


        # assume weight is in gms for the moment (need to contextualise on unit type for future)
        # need to know the default reference brewery details.  Lets assume 23L 75% eff for now.
        brewery_capacity = recipe.volume || brewery_capacity = 23.0
        brewery_efficiency = recipe.efficency || brewery_efficiency = 75.0
        brewery_efficiency = 100.0 unless fermentable_type.mashed

        lb_gal_to_kg_ltr =  0.1198264
        lb_per_kg =  2.2046226
        gal_per_ltr = 0.264172052

        #convert from str to float value
        begin
            new_weight = Float(new_weight_str)

            gu_lb_gal = fermentable_type.yeild/100.0 * brewery_efficiency/100 * 46.2
            weight_in_lbs = new_weight/1000.0 * lb_per_kg
            volume_in_gal = brewery_capacity * gal_per_ltr

            points_gu = weight_in_lbs/volume_in_gal * gu_lb_gal
        rescue
            points_gu = new_weight_str  # do this to ensure garbage value is picked up in subsequent validation
        ensure
            write_attribute(:points, points_gu)
        end
    end

    def weight
        if !fermentable_type then return 0.0 end
        brewery_capacity = recipe.volume || brewery_capacity = 23.0
        brewery_efficiency = recipe.efficency || brewery_efficiency = 75.0

        # logger.debug "++Recipe volume: #{recipe.volume}"

        brewery_efficiency = 100.0 unless fermentable_type.mashed

        lb_per_kg =  2.2046226
        gal_per_ltr = 0.264172052

        gu_lb_gal = fermentable_type.yeild/100.0 * brewery_efficiency/100 * 46.2

        weight_in_lbs = points / (gu_lb_gal) * brewery_capacity * gal_per_ltr
        weight_in_grms = weight_in_lbs / lb_per_kg * 1000

        return weight_in_grms
    end

    def amount
        self.weight
    end

    def percentage_points=(new_per_points)
    end

    def percentage_points
        return 0.0 if recipe.total_points <= 0.0

        per_points = points / recipe.total_points
        return per_points
    end

    def percentage_weight=(new_per_weight)

        return if (new_per_weight > 99 || new_per_weight < 1 )

        # copy db values to an array to iterate over.
        @fermentable_array = Array.new
        recipe.fermentables.each do |afermentable|
            if afermentable.id == self.id then# Skip the fermentable being operated on
                logger.debug("skipped self")
                next
            end
            @fermentable_array << afermentable
        end

        adjust_percentage_weight(new_per_weight)

        count = 5
        while( (percentage_weight - new_per_weight/100.0).abs > 0.0005)
            logger.debug "diff: #{percentage_weight - new_per_weight/100.0} count: #{count}"
            logger.debug "Reiterating calculation"
            logger.debug "Total weight: #{recipe.total_weight}"
            logger.debug "Percentage weight: #{percentage_weight}"

            adjust_percentage_weight( new_per_weight )
            count = count -1
            if( count == 0 ) then break end
        end

        # save fermentables to the database
        @fermentable_array.each do | afermentable |
            afermentable.save
        end
    end

    def percentage_weight
        return 0.0 if recipe.total_weight <= 0.0

        per_weight = weight / recipe.total_weight
        return per_weight
    end

    def adjust_percentage_weight( new_per_weight )

        # Need to calculate this independently of the database held values
        current_per_weight = 0.0
        current_total_weight = 0.0
        current_total_points = 0.0

        @fermentable_array.each do |afermentable|
            current_total_weight += afermentable.weight
            current_total_points += afermentable.points
        end
        current_total_weight += weight
        current_total_points += points

        current_weight = weight
        current_per_weight = weight / current_total_weight

        current_points = points
        current_other_points_total = current_total_points - current_points

        per_change = (new_per_weight/100.0) / current_per_weight

        logger.debug("per_change: #{per_change}")


        new_points = current_points * per_change

        # Update the weight value
        write_attribute(:points, new_points)

        logger.debug("old points: #{current_points} new_points: #{points}")

        # Determine the ratio to modify remaining items
        new_other_points_total = current_total_points - new_points
        logger.debug("cur other points: #{current_other_points_total} new_other_points: #{new_other_points_total}")

        other_points_change_ratio = new_other_points_total / current_other_points_total
        logger.debug("other_change_ratio: #{other_points_change_ratio}")

        # Update other fermentables
        @fermentable_array.each do |afermentable|
            afermentable.points = afermentable.points * other_points_change_ratio
            # afermentable.save
        end
    end

    def lock_weight
        return is_weight_locked?
    end


    def is_weight_locked?
        wla = read_attribute(:lock_weight)
        return is_weight_locked_func?( wla, recipe)
    end

    def ingr_type
        return self.fermentable_type
    end

    #  def is_weight_locked?
    #
    #    logger.debug "Checking lock weight attribute"
    #    a_locked = read_attribute(:lock_weight)
    #    return a_locked unless a_locked.nil?
    #
    #    #Default to false for a recipe, or a brew recipe that is still in planning phase (before brewday)
    #    logger.debug "Checking for planned brew"
    #    return false unless recipe.is_brewday?       #Defalt to false for a normal recipe.
    #    return false if recipe.is_brewday_planning?  #Default to false in planning phase
    #
    #    logger.debug "Brewday not in planning"
    #    #Default to lock if currently brewing or fermenting
    #    return true
    #  end

    #Hack to allow validation on virtual attributes
    def method_missing(symbol, *params)
        if (symbol.to_s =~ /^(.*)_before_type_cast$/)
            send $1
        else
            super
        end
    end


end
