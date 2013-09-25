require 'undev/capistrano'

set :application, 'shapado'

set :scm, :git
# TODO поменять репозитарий и ветку
set :repository, 'git@github.com:zabolotnov87/shapado.git'
set :branch, 'update_for_deploy'

# set :asset_packager, 'jammit'

set :use_sudo, false
set :undev_ruby_version, '1.9.3-p327'
default_run_options[:pty] = true
set :ssh_options, forward_agent: true

set :rake, "#{rake} --trace"

# TODO: вынести в config/deploy/production.rb
set :user, 'poweruser'
set :rails_env, :production
set :deploy_to, "/rest/u/apps/#{application}"
set :keep_releases, 5
role :web, '10.40.56.86'
role :app, '10.40.56.86'
role :db,  '10.40.56.86', :primary => true

namespace :bundle do
  task :install_binstubs do
    run "cd #{release_path} && bundle install --deployment --binstubs --path #{shared_path}/bundle --without development test"
  end
end

before "deploy:assets:precompile", "bundle:install_binstubs"

#  namespace :deploy do
#     task :restart, :roles => :app, :except => { :no_release => true } do
#      run "echo '#{`git describe`}' > #{current_path}/public/version.txt"
#      run "cd #{current_path} && ln -sf #{shared_path}/config/auth_providers.yml #{current_path}/config/auth_providers.yml"
#
#      assets.compass
#      assets.package
#
#      #magent.restart
#      bluepill.restart
#
#      run "rm -rf #{current_path}/tmp/cache/*"
#    end
#  end

#  require 'ricodigo_capistrano_recipes'
#
#  set(:websocket_remote_config) { "#{shared_path}/config/pills/websocket.pill"}
#  namespace :websocket do
#    desc "setup websocket pill"
#    task :setup do
#      generate_config("#{File.dirname(__FILE__)}/pills/websocket.pill.erb", websocket_remote_config)
#    end
#
#    desc "Init websocket with bluepill"
#    task :init do
#      rvmsudo "bluepill load #{websocket_remote_config}"
#    end
#
#    desc "Start websocket with bluepill"
#    task :start do
#      rvmsudo "bluepill websocket start"
#    end
#
#    desc "Restart websocket with bluepill"
#    task :restart do
#      websocket.stop
#      websocket.start
#    end
#
#    desc "Stop websocket with bluepill"
#    task :stop do
#      rvmsudo "bluepill websocket stop"
#    end
#
#    desc "Display the bluepill status"
#    task :status do
#      rvmsudo "bluepill websocket status"
#    end
#
#    desc "Stop websocket and quit bluepill"
#    task :quit do
#      rvmsudo "bluepill websocket stop"
#      rvmsudo "bluepill websocket quit"
#    end
#  end
