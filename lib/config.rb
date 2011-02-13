require 'singleton'

require 'spec_helper'

require 'rubygems'
require 'selenium-webdriver'
require "selenium/client"

module SeleniumHelpers
  class Configuration
    include Singleton
    
    attr_accessor :config

    def initialize
      @config = YAML.load(File.read(File.join(File.dirname(__FILE__), '..', 'conf', 'selenium.yml')))
    end
  end
end
