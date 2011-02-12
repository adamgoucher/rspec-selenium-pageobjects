require 'base_page'

module PageObjects
  class LoginPage < BasePage
    LOCATORS = {
      "username" => "username",
      "password" => "password",
      "submit_button" => "submit",
      "error_message" => "css=div.error p:nth(0)"
    }
    
    def initialize
      super
    end
    
    # elements
    def username=(username)
      @browser.type LOCATORS["username"], username
    end

    def password=(password)
      @browser.type LOCATORS["password"], password
    end

    def error_message
      @browser.get_text LOCATORS["error_message"]
    end
    
    # actions
    def login
      @browser.click LOCATORS["submit_button"], :wait_for => :page
    end
    
    
    
  end
end