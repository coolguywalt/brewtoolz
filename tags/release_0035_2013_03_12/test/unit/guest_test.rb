require File.dirname(__FILE__) + '/../test_helper'

class GuestTest < ActiveSupport::TestCase
 
  def test_create_user
    user = Guest.new
    
    #ensure we can get a units
    assert user.units()
    
    #Check the unit preference object is accessible
    assert user.units.volume
  end

  
end