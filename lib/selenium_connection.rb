require 'singleton'

require 'config'

require 'rubygems'
require 'selenium-webdriver'
require "selenium/client"

module SeleniumHelpers
  class SeleniumConnection
    include Singleton
    
    attr_accessor :connection

    def initialize
      @connection = Selenium::Client::Driver.new \
                      :host => SeleniumHelpers::Configuration.instance.config['selenium']['host'],
                      :port => SeleniumHelpers::Configuration.instance.config['selenium']['port'],
                      :browser => SeleniumHelpers::Configuration.instance.config['selenium']['browser'],
                      :url => SeleniumHelpers::Configuration.instance.config['selenium']['base_url'],
                      :timeout_in_second => SeleniumHelpers::Configuration.instance.config['selenium']['timeout']
    end
  end
end
