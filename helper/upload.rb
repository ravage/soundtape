require 'helper/exceptions'

module SoundTape
  module Helper
    
    class ImageResize
      def initialize(path)
        @image_path = path
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
      
      def cleanup
        FileUtils.rm @image_path if File.exist?(@image_path)
      end
      
      private
      
      def new_name(suffix)
        return @image_path.gsub('.', "#{suffix}.")
      end
    end
    
    class Upload
      def initialize(upload_info)
        @tempfile, @filename, @type = upload_info.values_at(:tempfile, :filename, :type)
      end

      def is_uploaded?
        return @tempfile.size > 0 && !@type.nil?
      end

      def tempfile
        return @tempfile
      end

      def mime_type
        return @type
      end

      def filename
        return File.basename(@filename)
      end

      def extension
        return File.extname(@filename)
      end

      def move_to(path)
        begin
          FileUtils.cp(tempfile.path, path)
        rescue Exception => e 
          raise UploadException, e
        ensure
          FileUtils.rm(tempfile.path) if File.exist?(tempfile.path)
        end
        @new_path = path
        return path
      end

      def copy_to(path)
        begin
          FileUtils.cp(tempfile.path, path)
        rescue Exception => e
          raise UploadException, e
        ensure
          FileUtils.rm(tempfile.path) if File.exist?(tempfile.path)
        end
        @new_path = path
        return path
      end
  
      def is_image?
        Kernel.const_set('Format', Struct.new(:length, :offset, :signature))
        formats = Hash.new
        formats['image/png'] = [Format.new(3, 1, '504e47')]
        formats['image/gif'] = [Format.new(3, 0, '474946')]
        formats['image/jpeg'] = [Format.new(4, 0, 'ffd8ffe0'), Format.new(4, 0, 'ffd8ffe1')]
        
        format = formats[mime_type]
    
        return false if format.nil?
    
        begin
          format.each do |f|
              return true if IO.read(tempfile.path, f.length, f.offset).unpack('H*').first == f.signature
          end
        rescue Exception => e
          raise UploadException, e
        end
        return false
      end
      
      def done?
        return File.exist?(@new_path)
      end
      
      def new_path
        return @new_path
      end
    end
  end
end