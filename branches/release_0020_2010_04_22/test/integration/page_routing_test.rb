require "#{File.dirname(__FILE__)}/../test_helper"

class PageRoutingTest < ActionController::IntegrationTest
	# fixtures :your, :models
	fixtures :users, :recipes

	# Replace this with your real tests.
	def test_front_page

		#Go to front page as guest user
		#- Front page screen
		get "/"
		assert_response :success
		assert_template "index"
		assert_select "h2", "Online recipe calculator"

		#Login in
		login_user_helper( 'slartibartfart', 'slarti' )

		#Go to front page as logged in user
		#- User specific front page with list of brewlogs etc
		get "/"
		assert_response :success
		assert_template "index"
		assert_select "div#member_div"

		#Close browser
		#Open browser and call up brewtoolz website
		#- Should still be logged in as user
		#Logout

		post "/logout"
		#- Guest front page should be displayed
		get "/"
		assert_response :success
		assert_template "index"
		assert_select "h2", "Online recipe calculator"


	end

	def login_user_helper( username, password )
		get "/login"
		post "/login", :login => username, :password => password
	end

	def test_login_page

		#normal login
		get "/login"
		assert_response :success
		assert_select "button", "Sign up"

	    post "/login", :login => 'slartibartfart', :password => 'slarti'
        assert_redirected_to "/"
		get "/"
		assert_select "div#member_div"

		#logout
        post "/logout"
        assert_redirected_to "/"
		get "/"
		assert_select "h2", "Online recipe calculator"


		#wrong password/username combo
	    post "/login", :login => 'slartibartfart', :password => 'wrong!'
		assert_response :success
        assert_equal flash[:error], "You did not provide a valid username and password."

	end

	def test_recipes_page
		# browse when not logged in
		get "/recipes"
		assert_response :success
		assert_select "h2", "Top rating Recipes"

		#browse when logged in
		login_user_helper( 'slartibartfart', 'slarti' )
		get "/recipes"
		assert_response :success
		assert_select "a", "New Recipe"

	end

	def test_brewlog_page
		# browse when not logged in
		get "/brew_entries"
		assert_response :success

		#browse when logged in
		login_user_helper( 'slartibartfart', 'slarti' )
		get "/brew_entries"
		assert_response :success
	end

	def test_breweries_page
		# browse when not logged in
		get "/breweries"
		assert_response :success

		#browse when logged in
		login_user_helper( 'slartibartfart', 'slarti' )
		get "/breweries"
		assert_response :success
		assert_select "a", "New Brewery"
	end

	def test_preferences_page
		# browse when not logged in
		get "/users/preferences"
		assert_response 404
		assert_select "h1", "The page you were looking for could not be found"

		#browse when logged in
		login_user_helper( 'slartibartfart', 'slarti' )
		get "/users/preferences/1"
		assert_response :success
		assert_select "h2", "Unit Preferences:"

	end


end
