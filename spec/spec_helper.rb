$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '../lib'))

require 'selenium_connection'

RSpec.configure { |c|
  c.before(:each) {
    @browser = SeleniumHelpers::SeleniumConnection.instance.connection
    @browser.start_new_browser_session
    @browser.window_maximize
    @browser.open("/")
  }

  c.after(:each) {
    @browser.close_current_browser_session
  }
}