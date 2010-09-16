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

module UnitsHelper

	$METRIC = "metric"
	$IMPERIAL = "imperial"
	$GRAMS = "gms"
	$KILOGRAMS = "kgs"
	$POUND = "lbs"
	$OUNCE = "oz"
	$LITRE = "ltr"
	$GALLON = "gal"
	$CELCIUS = "C"
	$FARENHEIT = "F"
	$SGRAVITY = "SG"
	$PLATO = "P"
	$POINTS = "points"
	$LTR_PER_KG = "ltr/kg"
	$QUARTS_PER_LB = "qt/lb"
  
	$DEF_VOLUME = 23 # 23 litres
  
	def gravity_values( value, auser=nil )
    auser = current_user if auser.nil?
		BrewingUnits::values_for_display( auser.units.gravity, value, 3 )
    
	end
  
	def gravity_units( auser=nil )
    auser = current_user if auser.nil?
		BrewingUnits::units_for_display( auser.units.gravity )
    
	end
  
	def gravity_value( value )
		BrewingUnits::value_for_display( current_user.units.gravity, value, 3 )
    
	end
  
	def gravity_unit( auser=nil )
    auser = current_user if auser.nil?
		BrewingUnits::unit_for_display( auser.units.gravity )
    
	end
  
	def ferm_weight_values(weight, auser=nil)
    auser = current_user if auser.nil?
		BrewingUnits::values_for_display( auser.units.fermentable, weight, 2 )
	end

  def self.ferm_weight_value(weight, auser = nil)
    auser = current_user if auser.nil?
		BrewingUnits::value_for_display( auser.units.fermentable, weight, 2 )
	end
 
	def ferm_weight_units
		BrewingUnits::units_for_display( current_user.units.fermentable )
	end
  
	def volume_values(vol, auser=nil )
    auser = current_user if auser.nil?
		BrewingUnits::values_for_display( auser.units.volume, vol, 2 )
	end

  def volume_value(vol)
		BrewingUnits::value_for_display( current_user.units.volume, vol, 2 )
	end

	def volume_units( auser=nil )
    auser = current_user if auser.nil?
		BrewingUnits::units_for_display( auser.units.volume )
	end
  
	def volume_unit( auser=nil )
    auser = current_user if auser.nil?
		BrewingUnits::unit_for_display( auser.units.volume )
	end
	
  def hop_weight_values(weight)
		BrewingUnits::values_for_display( current_user.units.hops, weight, 2 )
	end
  
	def hop_weight_units
		BrewingUnits::units_for_display( current_user.units.hops )
	end

	def hop_weight_unit
		BrewingUnits::unit_for_display( current_user.units.hops )
	end

	def temp_values(temp)
		BrewingUnits::values_for_display( current_user.units.temperature, temp, 2 )
	end
 
	def temp_units
		BrewingUnits::units_for_display( current_user.units.temperature )
	end

  def temp_unit
		BrewingUnits::unit_for_display( current_user.units.temperature )
	end

	def liquor_to_grist_units
		BrewingUnits::units_for_display( current_user.units.liquor_to_grist )
	end

	def liquor_to_grist_values(l_g)
		BrewingUnits::values_for_display( current_user.units.liquor_to_grist, l_g, 2 )
	end

  def liquor_to_grist_value(l_g)
		BrewingUnits::value_for_display( current_user.units.liquor_to_grist, l_g, 2 )
	end

	def temp_unit
		BrewingUnits::unit_for_display( current_user.units.temperature )
	end
  
  #	def decimal( value )
  #		number_with_precision( value, :precision => 2 )
  #	end
  #
  #	def percentage( value )
  #		number_to_percentage(value, :precision => 2)
  #	end
    

	def gms_to_lbs( wght_gms )
		lbs = BrewingUnits::to_lbs(wght_gms)
	end

	def ltrs_to_gal( vol_ltrs )
		# check for nil arguments
		return 0.0 unless vol_ltrs
		gal =  BrewingUnits::to_gal( vol_ltrs )
	end
  
  
	def self.input_fermentable_weight( weight, auser=nil )
    auser = current_user unless auser
		result= BrewingUnits::value_for_storage( auser.units.fermentable, weight)
		return result
	end
  
	def input_hops_weight( weight)
		result= BrewingUnits::value_for_storage( current_user.units.hops, weight)
		return result
	end
  
	def input_temperature( temp )
		result= BrewingUnits::value_for_storage( current_user.units.temperature, temp)
		return result
	end
  

	def temperature_display( value)
		display_value = BrewingUnits::value_for_display( current_user.units.temperature, value, 2)
		return display_value
	end

  def temperature_displays( value)
		display_value = BrewingUnits::values_for_display( current_user.units.temperature, value, 2)
		return display_value
	end

end
