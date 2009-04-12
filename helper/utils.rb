require 'helper/upload'
module Ramaze
  module Helper
    module Utils
      def oops(sender, exception)
        #TODO log into file and notify by mail
        Ramaze::Log.error "Exception: #{sender} => #{exception}"
        flash[:exception] = true
        redirect '/oops'
      end
      
      def prepare_flash(args = {})
        #pp errors
        flash[:error] = true
        args[:errors].each { |key, message| flash["error_#{args[:prefix]}_#{key.to_s}".to_sym] = message.first }
        request.params.each { |key, value| flash["#{args[:prefix]}_#{key}".to_sym] = value }
        pp flash
      end
    end
  end
end