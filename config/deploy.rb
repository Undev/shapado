require 'undev/capistrano'

set :application, 'shapado'

set :scm, :git

# TODO поменять репозитарий и ветку
set :repository, 'git@github.com:zabolotnov87/shapado.git'
set :branch, 'update_for_deploy'

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
  desc 'Install binstubs'
  task :install_binstubs, roles: :app do
    run "cd #{release_path} && bundle install --deployment --binstubs --path #{shared_path}/bundle --without development test"
  end
end

namespace :deploy do
  desc 'Create symlinks'
  task :create_symlinks, roles: :app do
    run "ln -nfs #{release_path}/config/shapado.yml.sample #{release_path}/config/shapado.yml"
    run "ln -nfs #{release_path}/config/mongoid.yml.sample #{release_path}/config/mongoid.yml"
  end

  # TODO: вынести в rake task + навести красоту
  desc 'Update geoip base'
  task :update_geoip, roles: :app do
    run "rm -f #{release_path}/shared/GeoLiteCity.dat.gz"
    run "mkdir -p #{release_path}/shared"
    run "cd #{release_path}/shared && wget -q http://www.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && gunzip -f GeoLiteCity.dat.gz"
  end

  desc 'Compile & package assets'
  task :process_assets, roles: :app do
    run "cd #{current_path} && bundle exec compass compile; true"
    run "cd #{current_path} && bundle exec jammit; true"
  end

  desc 'restart unicorn'
  task :restart_unicorn, roles: :app do
    run "sudo /usr/bin/sv restart /etc/service/shapado_unicorn"
  end
end

after 'deploy:update', 'bundle:install_binstubs', 'deploy:create_symlinks', 'deploy:update_geoip', 'deploy:process_assets'
after 'deploy:restart', 'deploy:restart_unicorn'
