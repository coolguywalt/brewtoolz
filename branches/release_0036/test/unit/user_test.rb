require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
 
  def test_create_user
    user = User.new
    assert !user.valid?
    
    #ensure we can get a units
    assert user.units()
    
    #Check the unit preference object is accessible
    assert user.units.volume
  end
  
  def test_get_brewery_info
      user = User.new
      assert !user.valid?
      
      assert user.default_brewery_efficency
      assert user.default_brewery_volume
  end
  
end
