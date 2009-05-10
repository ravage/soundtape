set :application, 'soundtape'
set :repository, 'ssh://fragmentized_git@fragmentized.net/home/fragmentized_git/git/soundtape.git'
set :scm, :git
set :deploy_to, '/home/ravage/ruby_apps'
server 'soundtape.net', :app, :web
