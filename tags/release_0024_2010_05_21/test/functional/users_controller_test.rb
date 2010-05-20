require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users
  
  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new  
  end
  
  def test_login_good
    assert_nil @request.session[:user]
    get :login
    user = users(:slarti)
    post :login, :login => user.username, :password => 'slarti'
    assert_not_nil @request.session[:user]
  end
  
    def test_login_bad
    assert_nil @request.session[:user] # = 1 # users(username).id
    get :login
    user = users(:slarti)
    post :login, :login => user.username, :password => 'wrong'
    assert_nil @request.session[:user]
  end
end
