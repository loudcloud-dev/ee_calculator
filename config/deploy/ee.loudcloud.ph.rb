# To load prod db: cap staging.ee.loudcloud.ph db:pull

set :stage, :"ee.loudcloud.ph"
set :branch, "production"
set :user, "ee_prod"

set :application, "ee_prod"

# files / directories that are just symlinks to entries in shared
set :linked_files, %w[ config/database.yml ]
set :linked_dirs, %w[ log tmp/pids tmp/cache tmp/sockets system public/system storage solr vendor .bundle ]

server "128.199.78.131", user: "ee_prod", roles: %w[web app db]

set :ssh_options, {
  forward_agent: true
}

# deploy location
set :full_app_name, "ee_prod"
set :deploy_to, "/home/ee_prod/ee_prod"

# init service name
set :service, "ee.loudcloud.ph"
set :worker_service, "ee.loudcloud.ph.sidekiq"

# rails settings
set :rails_env, "production"

set :rbenv_path, "/home/#{fetch(:user)}/.rbenv"
set :rbenv_type, :user
set :rbenv_ruby, "3.3.5"

set :tmp_dir, "/home/#{fetch(:user)}/.capistrano-tmp"
