require "#{File.expand_path(File.dirname(__FILE__))}/upload"
require "#{File.expand_path(File.dirname(__FILE__))}/image_resize"
require "#{File.expand_path(File.dirname(__FILE__))}/cleanup"

require 'iconv'
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
      
      def my_profile?
        return @user.id_ == session[:user_id]
      end
      
      def my_shout?(shout)
        return shout.post_by == session[:user_id]
      end
      
      def seo(value)
        #from http://github.com/technoweenie/permalink_fu
        result = Iconv.iconv('ascii//translit', 'utf-8', value).to_s
        result.gsub!(/[^\x00-\x7F]+/, '') #Remove anything non-ASCII entirely (e.g. diacritics).
        result.gsub!(/[^\w_ \-]+/i, '') #Remove unwanted chars.
        result.gsub!(/[ \-]+/i, '-') #No more than one of the separator in a row.
        result.gsub!(/^\-|\-$/i, '') #Remove leading/trailing separator.
        return result.downcase
      end
      
      def slug_it(model, value)
        return Digest::MD5.hexdigest(rand(Time.now + Time.now.usec).to_s) if value.empty?
        slug = seo(value)
        count = model.filter(:slug.like("#{slug}%")).count.to_i
        if(count == 0)
          return slug
        else
          return "#{slug}-#{count}"
        end
      end
            
    end
  end
end