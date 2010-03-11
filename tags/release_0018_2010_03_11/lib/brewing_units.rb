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
 

module BrewingUnits
  
  
  
  #  module ClassMethods
  #    
  #  end
  #  
  #  module InstanceMethods
  #    
  #  end
  #  
  #  def self.included(receiver)
  #    receiver.extend         ClassMethods
  #    receiver.send :include, InstanceMethods
  #  end
  #end 
  
  # Units for mass
  $GM = 1.0 # reference unit
  $KG = 0.001
  $OZ = 0.0352739619  # factor to convert a gm to lb measurement
  $LB = 0.00220462262 # factor to convert a gm to lb measurement
  
  # Units for volume
  $LTR = 1.0
  $HEC_LTR = 100.0
  $GAL = 3.785411789
  $QUART = 0.946352946
  
  # Gravity units
  # -- need a forumla for this
  
  # Temperature units
  # -- require formula
  
  
  #$METRIC = "metric"
  #$IMPERIAL = "imperial"
  #$GRAMS = "gms"
  #$KILOGRAMS = "kgs"
  #$POUND = "lbs"
  #$OUNCE = "oz"
  #$LITRE = "ltr"
  #$GALLON = "gal"
  #$CELCIUS = "C"
  #$FARENHEIT = "F"
  #$GRAVITY = "SG"
  #$PLATO = "P"
  
  #$GRAMS_TO_POUNDS = 0.00220462262
  #$GRAMS_TO_OUNCE = 0.0352739619
  #$KG_TO_GRAMS = 1000.0
  #$LITER_TO_GALLON = 0.264172052
  
  public
  
  def self.to_kgs( gm)
    return Float(gm) * $KG
  rescue
    return gm  #Garbage in, garbage out
  end
  
  def self.from_kgs( kg )
    return Float(kg) / $KG
  rescue
    return kg  #Garbage in, garbage out
  end
  
  def self.to_gms( gm )
    return Float(gm) / $GM
  rescue
    return gm  #Garbage in, garbage out
  end
  
  def self.from_gms( gm)
    return Float(gm) * $GM
  rescue
    return gm  #Garbage in, garbage out
  end
    
  def self.to_lbs( gm )
    return  Float(gm) * $LB
  rescue
    return gm  #Garbage in, garbage out
  end
  
  def self.from_lbs( lb )
    return  Float(lb) / $LB
  rescue
    return lb  #Garbage in, garbage out
  end
  
  def self.to_oz( gm )
    return Float(gm) * $OZ
  rescue
    return gm  #Garbage in, garbage out
  end
  
  def self.from_oz( oz )
    return Float(oz) / $OZ
  rescue
    return oz  #Garbage in, garbage out
  end
  
  def self.to_c( c )
    return Float(c)
  rescue
    return c  #Garbage in, garbage out
  end
  
  def self.from_c( c )
    return Float(c)
  rescue
    return c  #Garbage in, garbage out
  end
  
  def self.to_f( c )
    f = Float(c) * 9 / 5 + 32
    return f
  rescue
    return c  #Garbage in, garbage out
  end
  
  def self.from_f( f )
    c = (Float(f) - 32) * 5 / 9
    return c
  rescue
    return f  #Garbage in, garbage out
  end
  
  def self.to_sg( points ) 
    return 1.0 + Float(points) / 1000.0
  rescue
    return points  #Garbage in, garbage out
  end
  
  def self.from_sg( sg )
    return (Float(sg) - 1.0) * 1000.0
  rescue
    return sg  #Garbage in, garbage out
  end
  
  def self.from_p( p )
    p = Float(p)
    return p/(258.6-((p/258.2)*227.1)) * 1000.0
    # return ((259.0/(259.0 - p))-1.0)*1000.0
  rescue
    return p  #Garbage in, garbage out
  end
  #{Plato/(258.6-([Plato/258.2]*227.1)}+1  -- more accurate but will have to work out for both ways
  def self.to_p( points )
    points = Float(points)
    # return 259.0 - 259.0/(1.0 + points/1000.0)
    return (258.6*(points/1000.0)) / (1 + 227.1*(points/1000.0)/258.2)
  rescue
    return points  #Garbage in, garbage out
  end
  
  def self.from_points( points )
    return Float(points)
  end
  
  def self.to_points( points )
    return Float(points)
  rescue
	  points
  end
  
  def self.from_ltr (ltr)
    return Float(ltr)
  rescue
	  ltr
  end
  
  def self.to_ltr( ltr )
    return Float(ltr)
  rescue
	  ltr
end
  
  def self.from_gal( gal )
    return Float(gal) * $GAL
  rescue
    return gal  #Garbage in, garbage out
  end
  
  def self.to_gal( ltr )
    return Float(ltr) / $GAL
  rescue
    return ltr  #Garbage in, garbage out
  end



  def self.to_qt_per_lb( ltr_per_kg )
    return Float(ltr_per_kg) / 2.0864
  rescue
	return ltr_per_kg
  end

  def self.to_ltr_per_kg( ltr_per_kg )
    return Float(ltr_per_kg)
  rescue
	  return ltr_per_kg
  end

  def self.from_qt_per_lb( qrt_per_lb )
    return Float(qrt_per_lb) * 2.0864
  rescue
	  return qrt_per_lb
  end

  def self.from_ltr_per_kg( ltr_per_kg )
    return Float(ltr_per_kg)
  rescue
	  return ltr_per_kg
  end

  def self.unit_str( unit )

    logger.debug("Unit in: #{unit}")

      unit_str = unit.downcase
      unit_str = unit_str.sub(/\//, "_per_")

    logger.debug("Unit out: #{unit_str}")

      return unit_str
  end
  
  def self.values_for_display( unitstr, value, precision=2 ) 
    return nil if value == nil  # garbage in garbage out
    
    
    units = unitstr.split(' ')
    
    str = ""
    
    logger.debug("for_display unitstr:#{unitstr} value:#{value}" )
    for a in 0..units.length-1 do 
      str += " (" if a==1
      avalue = self.send('to_' + unit_str(units[a]), value )
      str += "%01.#{precision}f" % avalue
      str += ", " if (a > 0) and (a != units.length-1)
      str += ")" if a==units.length-1 and (a > 0)
    end
    
    logger.debug("for_display result: #{str}")
    
    return str
  
  #rescue
  #  :invalid
  end

  def self.value_for_display( unitstr, value, precision=2 ) 
    return nil if value == nil  # garbage in garbage out
    
    units = unitstr.split(' ')

    logger.debug("for_display unitstr:#{unitstr} value:#{value}" )

    avalue = self.send('to_' + unit_str(units[0]), value )
    str = "%01.#{precision}f" % avalue

    return str
  
  #rescue
  #  :invalid
  end
  
  def self.values_array_for_display( unitstr, value, precision=2 ) 
    units = unitstr.split(' ')
    
    str_array = Array.new()
    str= String.new()
      
    logger.debug("values_array_for_display unitstr:#{unitstr} units:#{units} value:#{value}" )
    for a in 0..units.length-1 do 
      avalue = self.send('to_' + unit_str(units[a]), value )
      str = "%01.#{precision}f" % avalue
      str_array.push(str)
    end
    
    logger.debug("for_display result: #{str_array}")
    
    return str_array
  
  #rescue
  #  [:invalid]
  end
  
  def self.units_for_display( unitstr ) 
    units = unitstr.split(' ')
    str = ""
    
    logger.debug("for_display unitstr:#{unitstr}" )
    
    for a in 0..units.length-1 do 
      str += " (" if a==1
      str += units[a]
      str += ", " if (a > 0) and (a != units.length-1)
      str += ")" if a==units.length-1 and (a > 0)
    end
    
    logger.debug("for_display result: #{str}")
    
    return str
  
  #rescue
  #  :invalid
  end

  def self.unit_for_display( unitstr ) 
    units = unitstr.split(' ')
    logger.debug("for_display unitstr:#{unitstr}" )
    str = units[0]
    
    logger.debug("for_display result: #{str}")
    
    return str
  
  #rescue
  #  :invalid
  end
  
  # Translates the value back into the default type for storage into the database.
  def self.value_for_storage( unitstr, value )
    units = unitstr.split(' ')
    avalue = self.send('from_' + unit_str(units[0]), value )
    
    return avalue
  end

def self.points_to_brix( points )
	sg = 1.0 + Float(points)/1000.0
	brix = -676.67 + 1286.4*sg - 800.47*(sg ** 2) + 190.74*(sg ** 3)
rescue
	return points
end

def self.refractomer_to_points( refract_reading, og_points )

	refract_reading = Float(refract_reading)
	og_points = Float(og_points)

	#og_as_plato = (BigDecimal.new(og_points.to_s)/1000.0-0.000019) / 0.00387863426128
	og_as_plato = points_to_brix(og_points)

	logger.debug "og_as_plato: #{og_as_plato}"

	#Formula for compensation of ethanol effect on refractometer:
	#    SG=1.001843-0.002318474(OB)-0.000007775(OB^2)-0.000000034(OB^3)+0.00574(AB) +0.00003344(AB^2)+0.000000086(AB^3)

	#SG = Specific Gravity, OB = Original Brix, AB = Actual Brix (Brix Readings During Fermentation)

	#Formula to convert from SG to Brix (for those who prefer Brix  measurements):

	#Brix (Plato) = -676.67 + 1286.4*SG - 800.47*(SG^2) + 190.74*(SG^3)


	# 1.001843
	# -0.002318474*(A$7)
	# -0.000007775*(A$7^2)
	# -0.000000034*(A$7^3)
	# +0.00574*($A11)
	# +0.00003344*($A11^2)
	# +0.000000086*($A11^3))
	# +(1.313454-0.132674*B11+0.002057793*(B11^2)-0.000002627634*(B11^3))*0.001;0)

	# refract_reading_bd = BigDecimal.new( refract_reading.to_s)

	#      points = 1.0
	#      points = 1.001843-0.002318474*(og_as_plato)
	#      points += -0.000007775*(og_as_plato**2)-0.000000034*(og_as_plato** 3)
	#      points += 0.00574*(refract_reading_bd)+0.00003344*(refract_reading_bd** 2)
	#      points += 0.000000086*(refract_reading_bd** 3)
	#      points = (points-1.0)*1000.0

	sg = 1.001843  -  0.002318474*(og_as_plato)  - 0.000007775*(og_as_plato**2)  - 0.000000034*(og_as_plato** 3)+ 0.00574*(refract_reading) +  0.00003344*(refract_reading ** 2) + 0.000000086*(refract_reading ** 3)

	points = (sg-1.0) * 1000.0

	return points

	rescue
      logger.error "refractometer conversion failed for: refract_reading - #{refract_reading}, og_points - #{og_points}"
	  return nil
end

  
  def self.logger
    RAILS_DEFAULT_LOGGER
  end

  def self.input_recipe_vol( volume, volume_units )
    volume = $DEF_VOLUME if !volume  # -- special case if no volume is available.
    result= BrewingUnits::value_for_storage( volume_units, volume)
    return result
  end

    def self.input_gravity( specific_gravity, gravity_units )
    result= BrewingUnits::value_for_storage( gravity_units, specific_gravity)
    
    return result
  end

end
