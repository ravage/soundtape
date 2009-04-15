require "#{File.expand_path(File.dirname(__FILE__))}/exceptions"

module SoundTape
  module Helper
    
    module ImageFormat
      class Format < Struct.new(:length, :offset, :signature); end
      
      def is_image?
        formats = Hash.new
        formats['image/png']  = [Format.new(3, 1, '504e47')]
        formats['image/gif']  = [Format.new(3, 0, '474946')]
        formats['image/jpeg'] = [Format.new(4, 0, 'ffd8ffe0'), Format.new(4, 0, 'ffd8ffe1')]
        formats['image/jp2']  = [Format.new(12, 0, '0000000c6a5020200d0a870a')]
        
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
    end
    
    class Upload
      include ImageFormat
      
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
          FileUtils.rm_f(tempfile.path)
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
          FileUtils.rm_f(tempfile.path)
        end
        @new_path = path
        return path
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