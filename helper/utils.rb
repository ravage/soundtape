require "#{File.expand_path(File.dirname(__FILE__))}/upload"
require "#{File.expand_path(File.dirname(__FILE__))}/image_resize"
require "#{File.expand_path(File.dirname(__FILE__))}/cleanup"
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
        flash[:error] = true
        args[:errors].each { |key, message| flash["error_#{args[:prefix]}_#{key.to_s}".to_sym] = message.first }
        request.params.each { |key, value| flash["#{args[:prefix]}_#{key}".to_sym] = value if value.is_a?(String) }
      end
      
      def settings?
        return action.instance.kind_of?(SettingsController) && logged_in?
      end
      
      def get_or_create_avatar_dir(user_id)
        path = File.join(SoundTape.options.Constant.upload_path, user_id.to_s, 'avatar')
        FileUtils.mkdir_p(path) unless File.exist?(path)
        return path
      end
      
      def get_or_create_photo_dir(user_id)
        path = File.join(SoundTape.options.Constant.upload_path, user_id.to_s, 'photos')
        FileUtils.mkdir_p(path) unless File.exist?(path)
        return path
      end
      
      def get_or_create_event_dir(user_id)
        path = File.join(SoundTape.options.Constant.upload_path, user_id.to_s, 'events')
        FileUtils.mkdir_p(path) unless File.exist?(path)
        return path
      end
      
      def get_or_create_album_dir(user_id)
        path = File.join(SoundTape.options.Constant.upload_path, user_id.to_s, 'albums')
        FileUtils.mkdir_p(path) unless File.exist?(path)
        return path
      end
      
    end
  end
end