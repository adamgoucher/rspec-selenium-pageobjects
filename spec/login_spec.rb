require 'spec_helper'
require 'home_page'

module "SauceWebsite" do
  describe "Logging in" do
    context "with an invalid password" do
      it "displays an error message", :depth => 'deep', :login => true do
        @home = PageObjects::HomePage.new
        @login = @home.goto_login_form
        @login.username = "foo"
        @login.password = "bar"
        @login.login
        # 'expectation'
        @login.error_message.should == "Incorrect username or password."
      end
    end
    
    context "with a correct password", :depth => 'shallow', :login => true do
      # if there is no block passed then it is 'pending
      it "goes to account page"
    end
  end
end