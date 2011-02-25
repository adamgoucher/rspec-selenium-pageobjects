$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '../lib'))

require 'selenium_connection'
require 'yaml'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure { |c|
  c.before(:all) {
    @config = SeleniumHelpers::Configuration.instance.config
  }
   
  c.before(:each) {
    @validation_errors = Array.new

    @browser = SeleniumHelpers::SeleniumConnection.instance.connection
    @browser.start_new_browser_session
    @browser.window_maximize
    @browser.open("/")
  }

  c.after(:each) {
    @browser.close_current_browser_session
    @validation_errors.should be_empty
  }
}