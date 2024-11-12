# To load prod db: cap staging.ee.loudcloud.ph db:pull

set :stage, :"staging.ee.loudcloud.ph"
set :branch, 'master'
set :user, 'ee_staging'

set :application, 'ee_staging'

# files / directories that are just symlinks to entries in shared
set :linked_files, %w{ config/database.yml }
set :linked_dirs, %w{ log tmp/pids tmp/cache tmp/sockets system public/system storage solr vendor .bundle }

server '159.65.140.204', user: 'ee_staging', roles: %w{web app db}

set :ssh_options, {
  forward_agent: true
}

# deploy location
set :full_app_name, "ee_staging"
set :deploy_to, "/home/ee_staging/ee_staging"

# init service name
set :service, 'staging.ee.loudcloud.ph'
set :worker_service, 'staging.ee.loudcloud.ph.sidekiq'

# rails settings
set :rails_env, 'production'

set :rbenv_path, "/home/#{fetch(:user)}/.rbenv"
set :rbenv_type, :user
set :rbenv_ruby, "3.3.5"

set :tmp_dir, "/home/#{fetch(:user)}/.capistrano-tmp"
