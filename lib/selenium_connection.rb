require 'singleton'

require 'rubygems'
require 'selenium-webdriver'
require "selenium/client"

module SeleniumHelpers
  class SeleniumConnection
    include Singleton
    
    attr_accessor :connection

    def initialize
      @connection = Selenium::Client::Driver.new \
                      :host => "localhost",
                      :port => 4444,
                      :browser => "*firefox",
                      :url => "http://saucelabs.com/",
                      :timeout_in_second => 20
    end
  end
end
