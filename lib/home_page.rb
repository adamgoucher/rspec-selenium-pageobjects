require 'base_page'
require 'login_page'

module PageObjects
  class HomePage < BasePage
    LOCATORS = {
      "login" => "css=div.account_mast a:first"
    }

    def initialize
      super
    end

    def goto_login_form
      @browser.click LOCATORS["login"], :wait_for => :page
      PageObjects::LoginPage.new
    end
    
  end
end