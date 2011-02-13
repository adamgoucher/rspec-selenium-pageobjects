require 'spec_helper'
require 'home_page'

module SauceWebsite
  describe "Login" do
    context "invalid password" do
      it "prints error message" do
        @home = PageObjects::HomePage.new
        @login = @home.goto_login_form
        @login.username = "foo"
        @login.password = "bar"
        @login.login
        # 'expectation'
        @login.error_message.should == "Incorrect username or password."
      end
    end
    
    context "correct password" do
      # if there is no block passed then it is 'pending
      it "goes to account page"
    end
  end
end