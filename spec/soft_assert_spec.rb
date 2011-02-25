require 'spec_helper'
require 'home_page'

module SauceWebsite
  describe "Login" do
    context "invalid password" do
      it "prints error message", :depth => 'deep', :login => true, :soft => true do
        @home = PageObjects::HomePage.new
        @login = @home.goto_login_form
        @login.username = "foo"
        @login.password = "bar"
        @login.login
        # 'expectation'
        begin
          @login.error_message.should == "Incofrrect username or password."
        rescue RSpec::Expectations::ExpectationNotMetError => verification_error
          @validation_errors << verification_error
        end
      end
    end
    
    context "correct password", :depth => 'shallow', :login => true do
      # if there is no block passed then it is 'pending
      it "goes to account page"
    end
  end
end