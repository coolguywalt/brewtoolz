require File.dirname(__FILE__) + '/../test_helper'

class GuestTest < ActiveSupport::TestCase
 
  def test_volume_conversion
    volume = 1.0
    
    gals = BrewingUnits.to_gal(1.0)
    assert_equal 1/3.785411789, gals 
       
    litre = BrewingUnits.from_ltr(1.0)
    assert_equal 1.0, litre
     
    litre = BrewingUnits.to_ltr(1.0)
    assert_equal 1.0, litre
    
    litre = BrewingUnits.from_gal(1/3.785411789)
    assert_equal 1.0, litre
  end

  def test_gravity_conversions
    points = BrewingUnits.from_p(5.0825920)
    assert check_tollerance( 20.0, points, 0.0001 )
    
    plato = BrewingUnits.to_p(67.0)
    assert check_tollerance( 16.3619896, plato, 0.0001 )
    
    points2 = BrewingUnits.from_p( plato)
    assert check_tollerance( 67.0, points2, 0.0001 )
    
    points = BrewingUnits.from_sg(1.078)
    assert check_tollerance( 78.0, points, 0.0001 )
    
    #points = BrewingUnits.from_sg(0.992)
    #assert check_tollerance( -8.0, points )
   
    sg = BrewingUnits.to_sg(78.9)
    assert_equal 1.0789, sg

  end
  
  def test_weight_conversions
  # $GM = 1.0 # reference unit
  # $KG = 0.001
  # $OZ = 0.0352739619  # factor to convert a gm to lb measurement
  # $LB = 0.00220462262 # factor to convert a gm to lb measurement
    #kg
    gm = BrewingUnits.from_kgs(78.9)
    assert_equal 78900, gm
  
    kg = BrewingUnits.to_kgs(1234)
    assert_equal 1.234, kg 

    gm2 = BrewingUnits.from_kgs(kg)
    assert_equal 1234, gm2 
        
    #oz
    gm = BrewingUnits.from_oz(78.9)
    assert_equal 78.900/0.0352739619, gm
  
    oz = BrewingUnits.to_oz(1234)
    assert_equal 1234*0.0352739619, oz 

    gm2 = BrewingUnits.from_oz(oz)
    assert_equal 1234, gm2  
    
    #lb
     gm = BrewingUnits.from_lbs(78.9)
    assert_equal 78.900/0.00220462262, gm
  
    lb = BrewingUnits.to_lbs(1234)
    assert_equal 1234*0.00220462262, lb 

    gm2 = BrewingUnits.from_lbs(lb)
    assert_equal 1234, gm2     

  end
  
  def test_temp_conversion
    c = BrewingUnits.from_f(12.0)
    assert_equal( (12.0-32.0)*5.0/9.0, c )
    
    f2 = BrewingUnits.to_f(c)
    assert_equal 12.0, f2
  
    f = BrewingUnits.to_f(0)
    assert_equal 32.0, f 

  end
  

end
