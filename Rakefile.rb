desc "Update pot/po files."
task :updatepo do
  require 'gettext/utils'
  GetText.update_pofiles("soundtape", Dir.glob("{model,controller,view}/**/*.{rb,rhtml}"), "soundtape 1.0.0")
end

desc "Create mo-files"
task :makemo do
  require 'gettext/tools'
  GetText.create_mofiles(:verbose => true, :podir => './locale')
  # GetText.create_mofiles(true, "po", "locale")  # This is for "Ruby on Rails".
end