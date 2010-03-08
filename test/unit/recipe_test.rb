require File.dirname(__FILE__) + '/../test_helper'

class RecipeTest < ActiveSupport::TestCase
  fixtures :recipes, :fermentables, :fermentable_types, :hops, :hop_types

  def test_color
    # Should test more than one point in colour scheme
    # these values have been checked against beersmith and manually using a spreadsheet
    recipe = recipes(:morey_colour)
    assert_in_delta(44.889,recipe.total_points(), 0.001)
    assert_in_delta(32.76361461, recipe.srm(), 0.1)
  
  end


  def test_hop_change_to_nochill_and_back
     recipe = recipes(:nochill_recipe)
     hop_type = hop_types(:fuggles)
     #add hop
     @hop = recipe.hops.create(:hop_type => @hop_type, :ibu_l => 10.0, :minutes => 60, :aa => @hop_type.aa)

    assert_equal 10.0, @hop.ibu_l
  end


end
