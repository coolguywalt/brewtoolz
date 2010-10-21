require File.dirname(__FILE__) + '/../test_helper'
 
class BrewEntriesControllerTest < ActionController::TestCase
  fixtures  :users, :brew_entries, :breweries
	# Replace this with your real tests.
  
  def setup
    @controller = BrewEntriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

  end
 
  #Test creating new log entry
#  def test_edit_log_entry_recipe_owner
#
#	entry_id = 1
#
#    logger.debug "test_edit_log_entry_recipe_owner"
#    login_user_helper( 'slartibartfart','slarti')
#
#    get :edit, :id=>entry_id
#    assert_response :success
#
#    #update details
#    #brew_entry = BrewEntry.find(1)
#    #brew_entry.
#
#    #Processing BrewEntriesController#update (for 1.1.1.210 at 2008-09-12 17:41:00) [PUT]
#    #Session ID: BAh7CToJdXNlciILdXNlcl8yOg5yZXR1cm5fdG8wOgxjc3JmX2lkIiU5ZDJl%0ANzQ2NDI0YTE0Y2M0NGRlOTYxMWRjMzc3Y2I0NiIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--9ac64a69e7750cb98eadaf82cc1455ce696d3c02
#    #Parameters: {"page_path"=>"brew_entries/edit", "authenticity_token"=>"aee6fc20be38b72cd5422148c4d7c7aef3696292", "_method"=>"PUT", "action"=>"update", "id"=>"46", "controller"=>"brew_entries", "brew_entry"=>{"actual_fg"=>"", "actual_og"=>"0.0", "brew_date"=>{"month"=>"9", "day"=>"12", "year"=>"2008"}, "bottled_kegged"=>{"month"=>"9", "day"=>"12", "year"=>"2008"}, "volume_to_ferementer"=>"12.0", "pitching_temp"=>"", "comment"=>""}}
#	  post :update, :id=>entry_id, :brew_entry=>{:actual_fg=>"", :actual_og=>"0.0",
#      :brew_date=>{:month=>"9", :day=>"12", :year=>"2008"},
#      :bottled_kegged=>{:month=>"9", :day=>"12", :year=>"2008"},
#      :volume_to_ferementer=>"12.0", :pitching_temp=>"", :comment=>""}
#    assert_redirected_to :action =>"show", :controller=>"brew_entries"
#
#	#update brew date
#	assert_not_equal( "2009-06-19", BrewEntry.find(entry_id).brew_date.to_s )
##Processing BrewEntriesController#update_date_entry (for 1.1.1.210 at 2009-07-04 21:51:37) [POST]
# # Session ID: BAh7CToOcmV0dXJuX3RvMDoJdXNlciILdXNlcl8yOgxjc3JmX2lkIiVkOGRi%0AMTI3NjNhMTliNWE1OGE1MWU2ZjIzYTFjOWU4ZSIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--a4f7be6dc2dd35400e7f26477f117f9a36f02ba5
# # Parameters: {"authenticity_token">"5260801ca475b2861026667dc048292c7e12b330", "action"=>"update_date_entry", "id"=>"82", "controller"=>"brew_entries", "brew_entry"=>{"brew_date"=>"June 19, 2009"}}
#	post :update_date_entry, :id=>entry_id, :brew_entry=>{:brew_date=>"June 19, 2009"}
#	assert_response :success
#
#	assert_equal( "2009-06-19", BrewEntry.find(entry_id).brew_date.to_s )
#
#
#	#update bottled/kegged
#	assert_not_equal( "2009-07-01", BrewEntry.find(entry_id).bottled_kegged.to_s )
##	Processing BrewEntriesController#update_date_entry (for 1.1.1.210 at 2009-07-04 22:14:40) [POST]
##  Session ID: BAh7CToOcmV0dXJuX3RvMDoJdXNlciILdXNlcl8yOgxjc3JmX2lkIiVkOGRi%0AMTI3NjNhMTliNWE1OGE1MWU2ZjIzYTFjOWU4ZSIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--a4f7be6dc2dd35400e7f26477f117f9a36f02ba5
##  Parameters: {"authenticity_token"=>"5260801ca475b2861026667dc048292c7e12b330", "action"=>"update_date_entry", "id"=>"82", "controller"=>"brew_entries", "brew_entry"=>{"bottled_kegged"=>"July 1, 2009"}}
#
#	post :update_date_entry, :id=>entry_id, :brew_entry=>{:bottled_kegged=>"July 1, 2009"}
#	assert_response :success
#
#	assert_equal( "2009-07-01", BrewEntry.find(entry_id).bottled_kegged.to_s )
#
#
#	#update volume to fermenter
#	assert_not_equal( 17, BrewEntry.find(entry_id).volume_to_ferementer )
#  #Processing BrewEntriesController#update_volume (for 1.1.1.210 at 2009-07-04 22:33:11) [POST]
#  #Session ID: BAh7CToOcmV0dXJuX3RvMDoJdXNlciILdXNlcl8yOgxjc3JmX2lkIiVkOGRi%0AMTI3NjNhMTliNWE1OGE1MWU2ZjIzYTFjOWU4ZSIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--a4f7be6dc2dd35400e7f26477f117f9a36f02ba5
#  #Parameters: {"commit"=>"Ok", "authenticity_token"=>"5260801ca475b2861026667dc048292c7e12b330", "action"=>"update_volume", "id"=>"82", "controller"=>"brew_entries", "volume"=>"23"}
#	post :update_volume, :id=>entry_id, :volume=>"17"
#	assert_response :success
#	assert_equal( 17, BrewEntry.find(entry_id).volume_to_ferementer )
#
#
#	#update OG
#	assert_not_equal( 67, BrewEntry.find(entry_id).actual_og )
#  # Processing BrewEntriesController#update_og (for 1.1.1.210 at 2009-07-04 22:38:30) [POST]
#  # Session ID: BAh7CToOcmV0dXJuX3RvMDoJdXNlciILdXNlcl8yOgxjc3JmX2lkIiVkOGRi%0AMTI3NjNhMTliNWE1OGE1MWU2ZjIzYTFjOWU4ZSIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--a4f7be6dc2dd35400e7f26477f117f9a36f02ba5
#  # Parameters: {"commit"=>"Ok", "og"=>"1.067", "authenticity_token"=>"5260801ca475b2861026667dc048292c7e12b330", "action"=>"update_og", "id"=>"82", "controller"=>"brew_entries"}
#	post :update_og, :id=>entry_id, :commit=>"Ok", :og=>"1.067"
#	assert_response :success
#	assert_equal( 67, BrewEntry.find(entry_id).actual_og )
#
#	#update FG
#	assert_not_equal( 12, BrewEntry.find(entry_id).actual_fg )
#	post :update_fg, :id=>entry_id, :commit=>"Ok", :fg=>"1.012"
#	assert_response :success
#	assert_equal( 12, BrewEntry.find(entry_id).actual_fg )
#
#	#Select a brewery
#    #Processing BrewEntriesController#update_brewery (for 1.1.1.210 at 2009-07-05 22:31:22) [POST]
#    #Session ID: BAh7CToOcmV0dXJuX3RvMDoJdXNlciILdXNlcl8yOgxjc3JmX2lkIiUzZjk5%0AY2RkMGExYzkzNzdiYTQyN2I3ZTRiY2FiMmM2MyIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--cec120a608c80a8e75443da3d4a66264b95d33a8
#    #Parameters: {"authenticity_token"=>"3ce5e6344b930620075e3ae638954e6407f2e2cf", "action"=>"update_brewery", "id"=>"82", "controller"=>"brew_entries", "brewery_id"=>"1"}
#	post :update_brewery, :id=>entry_id, :brewery_id=>"1"
#	assert_response :success
#	assert_equal( 1, BrewEntry.find(entry_id).brewery.id )
#	assert_equal( 21, BrewEntry.find(entry_id).volume_to_ferementer )
#
#	#Select different brewery
#	post :update_brewery, :id=>entry_id, :brewery_id=>"3"
#	assert_response :success
#	assert_equal( 3, BrewEntry.find(entry_id).brewery.id )
#	assert_equal( 250, BrewEntry.find(entry_id).volume_to_ferementer )
#
#
#	log_count  = BrewEntry.find(entry_id).brew_entry_logs.count
#	#Processing BrewEntriesController#add_entry (for 1.1.1.210 at 2009-07-05 23:07:04) [GET]
#    #Session ID: BAh7CToOcmV0dXJuX3RvMDoJdXNlciILdXNlcl8yOgxjc3JmX2lkIiUzZjk5%0AY2RkMGExYzkzNzdiYTQyN2I3ZTRiY2FiMmM2MyIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--cec120a608c80a8e75443da3d4a66264b95d33a8
#    #Parameters: {"type"=>"observation", "action"=>"add_entry", "id"=>"82", "controller"=>"brew_entries"}
#    get :add_entry, :id=>entry_id, :type=>"observation"
#	# Parameters: {"action"=>"edit", "id"=>"54", "controller"=>"brew_entry_logs"}
#	assert_redirected_to :action =>"edit", :controller=>"brew_entry_logs"
#    assert_equal( log_count+1, BrewEntry.find(entry_id).brew_entry_logs.count )
#
#		log_count  = BrewEntry.find(entry_id).brew_entry_logs.count
#    get :add_entry, :id=>entry_id, :type=>"tasting"
#	assert_redirected_to :action =>"edit", :controller=>"brew_entry_logs"
#    assert_equal( log_count+1, BrewEntry.find(entry_id).brew_entry_logs.count )
#
#  end
  
  def test_edit_log_entry_other_user
    logger.debug "test_edit_log_entry_other_user"
    
    login_user_helper( 'slartibartfart','slarti')
    get :edit, :id=>"4"
    
    assert_response 200
    #assert_redirected_to :action =>"show", :controller=>"brew_entries"
    #assert_equal flash[:error], 'Current user can not edit this entry.'
#    post :update, :id=>"4", :brew_entry=>{:actual_fg=>"", :actual_og=>"0.0",
#      :brew_date=>{:month=>"9", :day=>"12", :year=>"2008"},
#      :bottled_kegged=>{:month=>"9", :day=>"12", :year=>"2008"},
#      :volume_to_ferementer=>"12.0", :pitching_temp=>"", :comment=>""}
#
#    assert_redirected_to :action =>"show", :controller=>"brew_entries"
  end
  
  def test_create_new_log_entry_guest
    #Processing BrewEntriesController#edit (for 1.1.1.210 at 2008-09-12 17:18:02) [GET]
    #Session ID: BAh7CToJdXNlciILdXNlcl8yOgxjc3JmX2lkIiU2NzAyYjM2ZjY5NTg2NGE5%0AZWYwYzE4NzNjNTc3YTkwYjoOcmV0dXJuX3RvMCIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--b99a1c73ab21967ca6e39cc3a212a7e0f23440f8
    #Parameters: {"action"=>"edit", "id"=>"45", "controller"=>"brew_entries"}
    
    get :edit, :id=>"1"
    assert_response 200
    #assert_equal flash[:error], 'Current user can not edit this entry.'
  end
  
  #Test adding a new observation
  def test_add_observation
	  
  end


  #Test adding a new tasting
  def test_add_testing
	  
  end

end
