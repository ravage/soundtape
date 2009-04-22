require "#{File.expand_path(File.dirname(__FILE__))}/upload"
require "#{File.expand_path(File.dirname(__FILE__))}/image_resize"
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
      
      def settings?
        return Action.stack.first.instance.kind_of?(SettingsController)
      end
      
      def get_or_create_avatar_dir(user_id)
        path = File.join(SoundTape::Constant.upload_path, user_id.to_s, 'avatar')
        FileUtils.mkdir_p(path) unless File.exist?(path)
        return path
      end
      
      def get_or_create_photo_dir(user_id)
        path = File.join(SoundTape::Constant.upload_path, user_id.to_s, 'photos')
        FileUtils.mkdir_p(path) unless File.exist?(path)
        return path
      end
    end
  end
end