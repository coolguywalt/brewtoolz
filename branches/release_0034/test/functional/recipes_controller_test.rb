require File.dirname(__FILE__) + '/../test_helper'

class RecipesControllerTest < ActionController::TestCase
  fixtures :recipes, :users, :ingredient_unit_preferences, :fermentable_types, :hop_types
  
  def setup
    @controller = RecipesController.new
    #@controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

  end
  
  def test_guest_route_recipe_index
    get :index
    assert_response :success
  end
  #  
  def test_guest_route_recipe_show
    get :show, :id => 1
    assert_response :success
  end
  
  def test_invalid_guest_route_recipe_brew
    get :show, :id => 1
    assert_response :success
    
    get :brew, :id=>"1"
    
    # Check that guest user cannot edit
    assert_response :redirect
    assert_equal flash[:error], 'Guest user cannot create brew entry'

  end
  
  
  def test_guest_route_recipe_edit
    get :edit, :id => 1
      
    # Check that guest user cannot edit
    assert_response 200
    #assert_equal flash[:error], 'Edit - Permission denied.'
  end
    
  def test_valid_user_route_recipe_edit
    login_user_helper( 'slartibartfart', 'slarti' )
    get :edit, :id => 1
         
    assert_response :success

  end
  
  def test_invalid_user_route_recipe_edit
    login_user_helper( 'robert', 'robert' )
    get :edit, :id => 1
         
    # Check that guest user cannot edit
    assert_response 200
    #assert_equal flash[:error], 'Edit - Permission denied.'

  end
  
  def test_guest_create_recipe
    
    get :new
    
    # Check that guest user cannot edit
    assert_response 200
    #assert_equal flash[:error], 'Create - Permission denied.'
  end
  
  def test_validuser_create_recipe
    login_user_helper( 'slartibartfart','slarti')
    
    # --- get the recipe
    get :new
    assert_response :success
    
    # --- post details
    # Parameters: {"page_path"=>"recipes/new", "authenticity_token"=>"7002fcadde4d13e56da0f7d353325c9294209d58", "action"=>"create", "controller"=>"recipes", "recipe"=>{"name"=>"", "efficency"=>"70.0", "style_id"=>"", "description"=>"", "user_id"=>"2", "volume"=>"21.0"}}
    post :create, 
      :recipe => {:name => "beer", :efficency =>"70.0", :style_id=>"", :description=>"good one", :user_id=>"1", :volume=>"21.0"}
    assert_response :redirect
    
  end  
  
    def test_valid_user_route_recipe_brew
      
    login_user_helper( 'slartibartfart','slarti')  
    
    get :show, :id => 1
    assert_response :success
    
    get :brew, :id=>"1"
    assert_response :redirect
    assert_redirected_to :action =>"show", :controller=>"brew_entries"
  end
  
    def test_validuser_create_and_edit_recipe
      login_user_helper( 'slartibartfart','slarti')
    
    # --- get the recipe
      get :new
      assert_response :success
    
      # --- post details
      # Parameters: {"page_path"=>"recipes/new", "authenticity_token"=>"7002fcadde4d13e56da0f7d353325c9294209d58", "action"=>"create", "controller"=>"recipes", "recipe"=>{"name"=>"", "efficency"=>"70.0", "style_id"=>"", "description"=>"", "user_id"=>"2", "volume"=>"21.0"}}
      post :create, 
      :recipe => {:name => "shinny new test", :efficency =>"72.0", :style_id=>7, :description=>"good one", :user_id=>"1", :volume=>"21.0"}
      assert_response :redirect
    
      recipe_id = Recipe.find_by_name("shinny new test").id
      validuser_edit_recipe(recipe_id)
    end
  

    
  
  def test_validuser_edit_recipe
    login_user_helper('slartibartfart','slarti')
    
    validuser_edit_recipe(1)
  end  
  
  def validuser_edit_recipe( recipe_id )

    get :edit, :id => recipe_id     
    assert_response :success

    #Edit recipe details feilds
    # Parameters: {"authenticity_token"=>"7002fcadde4d13e56da0f7d353325c9294209d58", "_method"=>"put", "action"=>"update", "id"=>"32", "controller"=>"recipes", "recipe"=>{"name"=>"wolf", "style_id"=>"41", "description"=>"aa"}}
    edit_name_comments_style(recipe_id, "wolf", "1", "this is a daft test")
    assert_response :success   
    
    
    # -- volume
    edit_volume( recipe_id, '15' ) 
    assert_response :success 
    assert_equal( 15.0, Recipe.find(recipe_id).volume )     
    
     
    edit_volume( recipe_id, '-15' ) 
    assert_equal( 15, Recipe.find(recipe_id).volume )
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /Volume must be/
    end
    
     
    edit_volume(recipe_id, '0' ) 
    assert_equal( 15, Recipe.find(recipe_id).volume )
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /Volume must be/
    end
     
    edit_volume( recipe_id, 'aa' ) 
    assert_equal( 15, Recipe.find(recipe_id).volume )
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /Volume is not a number/
    end 

    # -- efficiency
    edit_efficency( recipe_id, '60.0' ) 
    assert_response :success 
    assert_equal( 60, Recipe.find(recipe_id).efficency ) 
    
    edit_efficency( recipe_id, 'aaa' ) 
    assert_equal( 60, Recipe.find(recipe_id).efficency ) 
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /Efficency is not a number/
    end 
     
     
    edit_efficency( recipe_id, '-10' ) 
    assert_equal( 60, Recipe.find(recipe_id).efficency )      
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /Efficency must be greater than 0/
    end 
     
    edit_efficency( recipe_id, '0.1' ) 
    assert_equal( 0.1, Recipe.find(recipe_id).efficency )  

    edit_efficency( recipe_id, '119.9' ) 
    assert_equal( 119.9, Recipe.find(recipe_id).efficency ) 
     
#    edit_efficency( recipe_id, '120.1' )
#    assert_equal( 119.9, Recipe.find(recipe_id).efficency )
#    # Check for error message
#    assert_select_rjs :replace_html do
#      assert_select "div#recipe_errors_div", /Efficency must be less than 120/
#    end
    
    #Add fermentables
    fermentable_count = Recipe.find(recipe_id).fermentables.count
    
    add_fermentable( recipe_id, fermentable_types(:ale_malt).id )
    fermentable_count_after_add = Recipe.find(recipe_id).fermentables.count
    assert_equal( fermentable_count+1, fermentable_count_after_add)
     
    add_fermentable( recipe_id, fermentable_types(:sugar).id )
    fermentable_count_after_add = Recipe.find(recipe_id).fermentables.count
    assert_equal( fermentable_count+2, fermentable_count_after_add)   

    add_fermentable( recipe_id, fermentable_types(:pils_malt).id )
    fermentable_count_after_add = Recipe.find(recipe_id).fermentables.count
    assert_equal( fermentable_count+3, fermentable_count_after_add)      
    
     
    #Edit fermentable
    ferm_id = Recipe.find(recipe_id).fermentables.last.id
    # -- points
    edit_fermentable_gravity( recipe_id, ferm_id, 1.023)
    assert_equal(23.0, Fermentable.find(ferm_id).points )
    
    edit_fermentable_gravity( recipe_id, ferm_id, 'aaaa')
    assert_equal(23.0, Fermentable.find(ferm_id).points ) 
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /Points Gravity or weight must be a number > 0/
    end 
    
    edit_fermentable_gravity( recipe_id, ferm_id, -7)
    assert_equal(23.0, Fermentable.find(ferm_id).points )    
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /Points Gravity or weight must be a number > 0/
    end      
    
    # -- weight
    edit_fermentable_weight( recipe_id, ferm_id, 2000000.0)
    assert( check_tollerance( 2000000.0, 0.001, Fermentable.find(ferm_id).weight ) ) #Need to cater for rounding errors

    edit_fermentable_weight( recipe_id, ferm_id, 256.0)
    assert( check_tollerance( 256.0, 0.001, Fermentable.find(ferm_id).weight ) ) #Need to cater for rounding errors

    edit_fermentable_weight( recipe_id, ferm_id, 'blah')
    assert( check_tollerance( 256.0, 0.001, Fermentable.find(ferm_id).weight ) ) #Need to cater for rounding errors
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /Gravity or weight must be a number > 0/
    end
    
    edit_fermentable_weight( recipe_id, ferm_id,-6.4)
    assert( check_tollerance( 256.0, 0.001, Fermentable.find(ferm_id).weight ) ) #Need to cater for rounding errors
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /Gravity or weight must be a number > 0/
    end 
      
    #Remove fermentable
    del_fermentable( recipe_id, ferm_id )
    assert_raise  ActiveRecord::RecordNotFound do
      Fermentable.find(ferm_id)     
    end
    
    #Add hops
    hop_count = Recipe.find(recipe_id).hops.count
    
    add_hop( recipe_id, hop_types(:cascade).id )
    hop_count_after_add = Recipe.find(recipe_id).hops.count
    assert_equal( hop_count+1, hop_count_after_add)
  
    add_hop( recipe_id, hop_types(:fuggles).id )
    hop_count_after_add = Recipe.find(recipe_id).hops.count
    assert_equal( hop_count+2, hop_count_after_add)    
    
    #Edit hop
    hop_id = Recipe.find(recipe_id).hops.last.id

    edit_hop_ibu( recipe_id, hop_id, 23.0)
    assert_equal(23.0, Hop.find(hop_id).ibu_l )

    edit_hop_ibu( recipe_id, hop_id, 'aaaa')
    assert_equal(23.0, Hop.find(hop_id).ibu_l )    
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /is not a number/
    end
    
    edit_hop_ibu( recipe_id, hop_id, -7.0)
    assert_equal(23.0, Hop.find(hop_id).ibu_l )    
    # Check for error message
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /must be greater than or equal to 0/
    end  
    
    # --- check AA% and hop weight
    edit_hop_aa( recipe_id, hop_id, 23.0)
    assert_equal(23.0, Hop.find(hop_id).aa )
   
    edit_hop_aa( recipe_id, hop_id, 'aaa')
    assert_equal(23.0, Hop.find(hop_id).aa )
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /is not a number/
    end
    
    edit_hop_aa( recipe_id, hop_id, -9)
    assert_equal(23.0, Hop.find(hop_id).aa )
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /must be greater than 0/
    end  
    
    edit_hop_weight( recipe_id, hop_id, 23.0)
    assert check_tollerance( 23.0, 0.001, Hop.find(hop_id).weight )    

    edit_hop_weight( recipe_id, hop_id, 'sdsdf')
    assert check_tollerance( 23.0, 0.001, Hop.find(hop_id).weight )    
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /must be a number/
    end
    
    edit_hop_weight( recipe_id, hop_id, -7)
    assert check_tollerance( 23.0, 0.001, Hop.find(hop_id).weight )    
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /must be greater than or equal to 0/
    end
    
    edit_hop_minutes( recipe_id, hop_id, 15)
    assert_equal(15, Hop.find(hop_id).minutes )
  
    edit_hop_minutes( recipe_id, hop_id, 'sdfds')
    assert_equal(15, Hop.find(hop_id).minutes )
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /is not a number/
    end 
    
    edit_hop_minutes( recipe_id, hop_id, -15)
    assert_equal(15, Hop.find(hop_id).minutes )
    assert_select_rjs :replace_html do
      assert_select "div#recipe_errors_div", /must be greater than or equal to -1/
    end   
    
    #Remove hop
    del_hop( recipe_id, hop_id )
    assert_raise  ActiveRecord::RecordNotFound do
      Hop.find(hop_id)     
    end
    
    
    #Add yeast
    yeast_count = Recipe.find(recipe_id).yeasts.count
    
    add_yeast( recipe_id, yeast_types(:hefe).id )
    yeast_count_after_add = Recipe.find(recipe_id).yeasts.count
    assert_equal( yeast_count+1, yeast_count_after_add)   
    
    add_yeast( recipe_id, yeast_types(:calale).id )
    yeast_count_after_add = Recipe.find(recipe_id).yeasts.count
    assert_equal( yeast_count+2, yeast_count_after_add)
    
    #Remove yeast
    yeast_id = Recipe.find(recipe_id).yeasts.last.id
    del_yeast( recipe_id, yeast_id )
    assert_raise  ActiveRecord::RecordNotFound do
      Yeast.find(yeast_id)     
    end
  end
  
  def test_edit_recipe_name_style_comment
    recipe_id = 1
    username = 'slartibartfart'
    password = 'slarti'
    
    login_user_helper(username, password)
    get :edit, :id => recipe_id
    assert_response :success    
    
    edit_name_comments_style(recipe_id, "wolf", "3", "this is a daft test")
    assert_response :success

  end  
   
   
  def edit_name_comments_style( recipe_id, name, comment, style_id )
    xml_http_request :put, :update, 
      { :id =>recipe_id, 
      :recipe => {:name => name, :style_id => style_id, :description => comment} }
  end
  
  def edit_volume( recipe_id, volume )
    xml_http_request :put, :update, 
       {  :id =>recipe_id, :recipe => { :volume => volume } }
  end
  
  def edit_efficency( recipe_id, efficency )
    xml_http_request :put, :update, 
      { :id =>recipe_id, :recipe => { :efficency => efficency } }
  end
  
  def add_fermentable( recipe_id, fermentable_type )
    #  Processing RecipesController#add_fermentable (for 1.1.1.210 at 2008-09-01 22:43:34) [POST]
    #  Session ID: BAh7CToJdXNlciILdXNlcl8yOgxjc3JmX2lkIiVhNGQ0ZGI2YTNhMTUzOTNk%0AMGQ1ZDcyNTZiZDI2Njc0NToOcmV0dXJuX3RvMCIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--39c344beab80c5f831c37cf9beb06107fc9bdf0b
    #  Parameters: {"authenticity_token"=>"ad5f4395deb6df752ba7b58115bd1cde86ab0315", "ferementable_type_id"=>"1", "action"=>"add_fermentable", "id"=>"45", "controller"=>"recipes"}

    xml_http_request :put, :add_fermentable, 
      { :id =>recipe_id, :ferementable_type_id => fermentable_type }
  end
  
    def add_hop( recipe_id, hop_type )
    #  Processing RecipesController#add_hop (for 1.1.1.210 at 2008-09-01 22:43:34) [POST]
    #  Session ID: BAh7CToJdXNlciILdXNlcl8yOgxjc3JmX2lkIiVhNGQ0ZGI2YTNhMTUzOTNk%0AMGQ1ZDcyNTZiZDI2Njc0NToOcmV0dXJuX3RvMCIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--39c344beab80c5f831c37cf9beb06107fc9bdf0b
    #  Parameters: {"authenticity_token"=>"ad5f4395deb6df752ba7b58115bd1cde86ab0315", "ferementable_type_id"=>"1", "action"=>"add_hop", "id"=>"45", "controller"=>"recipes"}

    xml_http_request :put, :add_hop, 
      { :id =>recipe_id, :hop_type_id => hop_type }
  end
  
  def edit_fermentable_gravity( recipe_id, fermentable_id, gravity )
    #  Processing RecipesController#update_fermentable_points (for 1.1.1.210 at 2008-09-02 08:17:23) [POST]
    #  Session ID: BAh7CToJdXNlciILdXNlcl8yOg5yZXR1cm5fdG8wOgxjc3JmX2lkIiU0Zjhi%0AZGRkZGNlY2RlZDE5MWZhYTJkY2RkMTBmYjQ2OSIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--a8ab0281ffad4e22fbff1af94eb44dc6075680b7
    #  Parameters: {"commit"=>"Ok", "points"=>"7.000", "authenticity_token"=>"ce1108115f1b4d14cbf16fa03ffd21491ce9d7b0", "fermentable_id"=>"118", "action"=>"update_fermentable_points", "id"=>"33", "controller"=>"recipes"}
      
    xml_http_request :put, :update, 
      { :id => fermentable_id, :fermentable => {:points => gravity }  }
  end

  def edit_fermentable_weight( recipe_id, fermentable_id, weight )
    
    xml_http_request :put, :update_fermentable_weight, 
      { :id =>recipe_id, :fermentable_id => fermentable_id, :weight => weight, :commit => "OK" }
  end  
  
  def del_fermentable( recipe_id, fermentable_id )
    
    xml_http_request :put, :remove_fermentable, 
      { :id =>recipe_id, :comment => fermentable_id }
  end        
      
  def edit_hop_ibu( recipe_id, hop_id, ibu )
    xml_http_request :put, :update_hop_ibu, 
      { :id =>recipe_id, :hop_id => hop_id, :ibu => ibu, :commit => "OK" }
  end
  def edit_hop_aa( recipe_id, hop_id, aa )
    xml_http_request :put, :update_hop_aa, 
      { :id =>recipe_id, :hop_id => hop_id, :aa => aa, :commit => "OK" }
  end
    def edit_hop_weight( recipe_id, hop_id, weight )
    xml_http_request :put, :update_hop_weight, 
      { :id =>recipe_id, :hop_id => hop_id, :weight => weight, :commit => "OK" }
  end
      def edit_hop_minutes( recipe_id, hop_id, minutes )
    xml_http_request :put, :update_hop_minutes, 
      { :id =>recipe_id, :hop_id => hop_id, :minutes => minutes, :commit => "OK" }
  end
    def del_hop( recipe_id, hop_id )
    
    xml_http_request :put, :remove_hop, 
      { :id =>recipe_id, :hop_id => hop_id }
  end 
  
        def add_yeast( recipe_id, yeast_type )
    #  Processing RecipesController#add_hop (for 1.1.1.210 at 2008-09-01 22:43:34) [POST]
    #  Session ID: BAh7CToJdXNlciILdXNlcl8yOgxjc3JmX2lkIiVhNGQ0ZGI2YTNhMTUzOTNk%0AMGQ1ZDcyNTZiZDI2Njc0NToOcmV0dXJuX3RvMCIKZmxhc2hJQzonQWN0aW9u%0AQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsABjoKQHVzZWR7AA%3D%3D--39c344beab80c5f831c37cf9beb06107fc9bdf0b
    #  Parameters: {"authenticity_token"=>"ad5f4395deb6df752ba7b58115bd1cde86ab0315", "ferementable_type_id"=>"1", "action"=>"add_hop", "id"=>"45", "controller"=>"recipes"}

    xml_http_request :put, :add_yeast, 
      { :id =>recipe_id, :yeast_type_id => yeast_type }
  end
  
    def del_yeast( recipe_id, yeast_id )
    
    xml_http_request :put, :remove_yeast, 
      { :id =>recipe_id, :yeast_id => yeast_id }
  end
        
  def check_tollerance( ref_value, value, tollerance )
    return ref_value+ref_value*tollerance > value &&  ref_value-ref_value*tollerance < value
  end
      
end
