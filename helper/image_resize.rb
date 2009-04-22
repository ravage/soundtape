require "#{File.expand_path(File.dirname(__FILE__))}/exceptions"

module SoundTape
  module Helper

    class ImageResize
      attr_reader :image_path

      def cleanup
        FileUtils.rm_f(@image_path)
      end

      protected

      def initialize(path)
        @image_path = path
      end

      def new_name(suffix)
        return @image_path.gsub('.', "_#{suffix}.")
      end

      module ImageScience
        require 'image_science'
        def resize(width, height)
          new_path = new_name(width)
          ::ImageScience.with_image(@image_path) do |image|
            if image.height != height || image.width != width
              image.resize(width, height) do |resize|
                resize.save(new_path)
              end
            else
              FileUtils.cp(@image_path, new_path)
            end
          end
          return new_path
        end
        
        def crop(size)
          new_path = new_name(size)
          ::ImageScience.with_image(@image_path) do |image|
            image.cropped_thumbnail(size) do |crop|
              crop.save(new_path)
            end
          end
          return new_path
        end
      end

    end
  end
end