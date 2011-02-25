module Providers
  module Static
    class UsernamePassword
      attr_accessor :user
      
      def initialize
        @user = {
          "username" => "flying",
          "password" => "monkey"
        }
      end
    end
  end
end