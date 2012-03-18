set :application, "casadelkrogh_blog"
set :repository,  "git://github.com/mkrogh/CasaDelKrogh-Blog.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "momus.boundless.dk"                          # Your HTTP server, Apache/etc
role :app, "momus.boundless.dk"                          # This may be the same as your `Web` server

set :deploy_to, "/var/www/#{application}"
set :use_sudo, false

set :user, "markusk"
set :normalize_asset_timestamps, false

#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

task :set_permissions do
  run "chgrp -R www-data #{deploy_to}"
  run "chmod -R g+w #{deploy_to}"
end

namespace :deploy do
  task :update_jekyll do
    run "jekyll --no-auto #{release_path} #{release_path}/_site"
  end
end

after 'deploy', 'set_permissions'
after 'deploy:setup', 'set_permissions'
after 'deploy:update_code', "deploy:update_jekyll"
