require 'spec_helper'
require 'home_page'

require 'providers'
include Providers::Static
include Providers::CSV

module SauceWebsite
  describe "Logging in" do
    before(:each) do
      @home = PageObjects::HomePage.new
      @login = @home.goto_login_form
    end
    
    context "with an invalid password" do
      context "not using a provider" do
        it "displays an error message", :depth => 'deep', :login => true do
          @login.username = "foo"
          @login.password = "bar"
          @login.login
          # 'expectation'
          @login.error_message.should == "Incorrect username or password."
        end
      end
    
      context "using a static provider" do
        it "prints error message", :depth => 'deep',
                                   :login => true do
          provided_info = Providers::Static::UsernamePassword.new
          @login.username = provided_info.user["username"]
          @login.password = provided_info.user["password"]
          @login.login
          # 'expectation'
          @login.error_message.should == "Incorrect username or password."
        end
      end
    
      context "using a csv provider" do
        context "using a csv provider" do
          it "prints error message", :depth => 'deep',
                                     :login => true do
            provider = Providers::CSV::UsernamePassword.new
            provided_info = provider.random_row
            @login.username = provided_info[0]
            @login.password = provided_info[1]
            @login.login
            # 'expectation'
            @login.error_message.should == "Incorrect username or password."
          end
        end
      end
    end
    
    context "with a correct password", :depth => 'shallow', :login => true do
      # if there is no block passed then it is 'pending
      it "goes to account page"
    end
  end
end