module Ramaze
  module Helper
    module Utils
      def oops(sender, exception)
        #TODO log into file and notify by mail
        Ramaze::Log.error "Exception: #{sender} => #{exception}"
        flash[:exception] = true
        redirect '/oops'
      end
      
      def prepare_flash(errors)
        pp errors
        flash[:error] = true
        errors.each do |key, message|
           flash["error_#{key.to_s}".to_sym] = message
         end

         request.params.each do |key, value|
           flash[key.to_sym] = value
         end
      end
    end
  end
end