ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def login_user_helper( username, password ) 
    @curcontroller = @controller
    @controller = UsersController.new
    get :login
    post :login, :login => username, :password => password
    
    #get :login
    #user = users(:slarti)
    #post :login, :login => 'slartibartfart', :password => 'slarti'
    
    @controller = @curcontroller
  end
  
  def check_tollerance( ref_value, value, tollerance = 0.001 )
    return ref_value+ref_value*tollerance > value &&  ref_value-ref_value*tollerance < value
  end
  
  def logger
    RAILS_DEFAULT_LOGGER
  end
  
end

# Request Forgery Protection hack
# form_authenticity_token causes an error in test mode because protect_against_forgery is turned off.
module ActionController
  module RequestForgeryProtection
    def form_authenticity_token
      return "form_authenticity_token OVERRIDE!"
    end
  end
end

