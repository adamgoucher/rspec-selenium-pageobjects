require 'singleton'

require 'config'
require 'json'

require 'rubygems'
require 'selenium-webdriver'
require "selenium/client"

module SeleniumHelpers
  class SeleniumConnection
    include Singleton
    
    attr_accessor :connection

    def initialize
      if SeleniumHelpers::Configuration.instance.config['saucelabs']['ondemand']
        browser_string = {:username => SeleniumHelpers::Configuration.instance.config['saucelabs']['credentials']['username'],
                          :"access-key" => SeleniumHelpers::Configuration.instance.config['saucelabs']['credentials']['key'],
                          :os => SeleniumHelpers::Configuration.instance.config['saucelabs']['browser']['os'],
                          :browser => SeleniumHelpers::Configuration.instance.config['saucelabs']['browser']['browser'],
                          :"browser-version" => SeleniumHelpers::Configuration.instance.config['saucelabs']['browser']['version']
          }
        @connection = Selenium::Client::Driver.new \
                        :host => SeleniumHelpers::Configuration.instance.config['saucelabs']['server']['host'],
                        :port => SeleniumHelpers::Configuration.instance.config['saucelabs']['server']['port'],
                        :browser => browser_string.to_json,
                        :url => SeleniumHelpers::Configuration.instance.config['selenium']['base_url'],
                        :timeout_in_second => SeleniumHelpers::Configuration.instance.config['selenium']['timeout']
      else
        @connection = Selenium::Client::Driver.new \
                        :host => SeleniumHelpers::Configuration.instance.config['selenium']['host'],
                        :port => SeleniumHelpers::Configuration.instance.config['selenium']['port'],
                        :browser => SeleniumHelpers::Configuration.instance.config['selenium']['browser'],
                        :url => SeleniumHelpers::Configuration.instance.config['selenium']['base_url'],
                        :timeout_in_second => SeleniumHelpers::Configuration.instance.config['selenium']['timeout']
      end
    end
  end
end
