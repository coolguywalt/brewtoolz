require File.dirname(__FILE__) + '/../test_helper'

class BrewingUnitsTest < ActiveSupport::TestCase

  def test_refractometer_conversion

    gravity_reading = BrewingUnits::refractomer_to_points(13.0, 54.0)
    assert_in_delta(50.0  ,gravity_reading, 1.0)

    gravity_reading = BrewingUnits::refractomer_to_points(12.0, 54.0)
    assert_in_delta(43.0  ,gravity_reading, 1.0)

    gravity_reading = BrewingUnits::refractomer_to_points(11.0, 54.0)
    assert_in_delta(36.0  ,gravity_reading, 1.0)

    gravity_reading = BrewingUnits::refractomer_to_points(10.0, 54.0)
    assert_in_delta(30.0  ,gravity_reading, 1.0)

    gravity_reading = BrewingUnits::refractomer_to_points(9.0, 54.0)
    assert_in_delta(24.0  ,gravity_reading, 1.0)


    gravity_reading = BrewingUnits::refractomer_to_points(8.0, 54.0)
    assert_in_delta(17.0  ,gravity_reading, 1.0)

    gravity_reading = BrewingUnits::refractomer_to_points(7.0, 54.0)
    assert_in_delta(11.0  ,gravity_reading, 1.0)

    gravity_reading = BrewingUnits::refractomer_to_points(6.0, 54.0)
    assert_in_delta(5.0  ,gravity_reading, 1.0)
  end

end
