module Ramaze
  module Helper
    module Utils
      def oops(sender, exception)
        #TODO log into file and notify by mail
        Ramaze::Log.error "Exception: #{sender} => #{exception}"
      end
    end
  end
end