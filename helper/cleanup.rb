module SoundTape
  module Helper
    module_function
    def remove_files(*files)
      FileUtils.rm_rf(files, :secure => true)
    end
  end
end