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
        return @image_path.gsub('.', "#{suffix}.")
      end

      module ImageScience
        require 'image_science'
        def resize(suffix, width, height)
          ::ImageScience.with_image(@image_path) do |image|
            if image.height != height || image.width != width
              image.resize(width, height) do |resize|
                resize.save(new_name(suffix))
              end
            else
              FileUtils.cp(@image_path, new_name(suffix))
            end
          end
        end
      end

    end
  end
end