set :application, 'soundtape'
set :repository, 'ssh://fragmentized_git@fragmentized.net/home/fragmentized_git/git/soundtape.git'
set :scm, :git
set :deploy_to, "/home/ravage/ruby_apps/#{application}"
set :deploy_via, :remote_cache
server 'soundtape.net', :app, :web
set :use_sudo, false

after 'deploy', 'options'

task :options do
  system("scp options.rb ravage@soundtape.net:/#{deploy_to}/current/.")
end

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "thin -C /etc/thin/soundtape.yml start" 
  end
  
  task :stop, :roles => [:web, :app] do
    run "thin -C /etc/thin/soundtape.yml stop" 
  end
  
  task :restart, :roles => [:web, :app] do
     deploy.stop
     deploy.start
   end
end