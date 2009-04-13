require "#{File.expand_path(File.dirname(__FILE__))}/exceptions"

module SoundTape
  module Helper
    
    module Resize
      def resize(suffix, width, height)
        raise "method resize(suffix, width, height) not implemented for class #{self.class}"
      end
    end
    
    class ImageResize
      include Resize
      
      #TODO class should not be instanciated, hide method new()
      attr_reader :image_path
      
      def cleanup
        FileUtils.rm_f(@image_path)
      end

      protected
      
      def initialize(path)
        @image_path = path
      end
      
      def new_name(suffix)
        return @image_path.gsub('.', "#{suffix}.")
      end
      
      private
      
      def self.factory(path, opts = { :library => 'image_science' } )
        unless opts.empty?
          begin
            require opts[:library]
          rescue LoadError => e
            raise "library #{opts[:library]} not found"
          end
        end
        
        case opts[:library]
        when 'image_science'
          return ImageResizeImageScience.new(path)
        when 'rmagick'
          return ImageResizeRMagick.new(path)
        when 'im_magick'
          return ImageResizeImMagick.new(path)
        end
      end
    end
    
    class ImageResizeImageScience < ImageResize
      def initialize(path)
        super(path)
      end
      
      def resize(suffix, width, height)
         begin
           ImageScience.with_image(@image_path) do |image|
             if image.height != height || image.width != width
               image.resize(width, height) do |resize|
                 resize.save(new_name(suffix))
               end
             else
               FileUtils.cp(@image_path, new_name(suffix))
             end
           end
         rescue Exception => e
           raise ImageResizeException, e
         end
       end
    end
    
    class ImageResizeRMagick < ImageResize
      def initialize(path)
        super(path)
      end
    end
    
    class ImageResizeImMagick < ImageResize
      def initialize(path)
        super(path)
      end
    end
    
  end
end