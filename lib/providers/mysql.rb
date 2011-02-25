require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config'))
include SeleniumHelpers

module Providers
  module Database
    class MySQL
      def initialize
        require 'mysql'

        @dbh = Mysql.real_connect(SeleniumHelpers::Configuration.instance.config['mysql']['host'],
                                  SeleniumHelpers::Configuration.instance.config['mysql']['user'],
                                  SeleniumHelpers::Configuration.instance.config['mysql']['password'],
                                  SeleniumHelpers::Configuration.instance.config['mysql']['database'])
      end
      
      def random_username_and_password
        res = @dbh.query("select username, password from provider order by rand() limit 1")
        res.fetch_row
      end
    end
  end
end
