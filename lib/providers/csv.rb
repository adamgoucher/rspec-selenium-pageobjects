module Providers
  module CSV
    class UsernamePassword
      attr_accessor :user, :csv_content
      
      def initialize
        require 'faster_csv'

        @user = Hash.new
        @csv_content = FasterCSV.read(File.join(File.dirname(__FILE__), 'usernamepassword.csv'))
      end
      
      def random_row
        @csv_content[rand(csv_content.size)]
      end
    end
  end
end