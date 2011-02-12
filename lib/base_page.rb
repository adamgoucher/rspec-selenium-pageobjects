require 'selenium_connection'

module PageObjects
  class BasePage
    def initialize
      @browser = SeleniumHelpers::SeleniumConnection.instance.connection
    end
  end
end