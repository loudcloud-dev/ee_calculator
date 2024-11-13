# Add in Gemfile:
# gem 'capistrano'
# gem 'capistrano-rails'
# gem 'capistrano-bundler'
# gem 'capistrano-rbenv'
# gem 'capistrano-db-tasks', require: false

# config valid only for Capistrano 3.10
lock "~> 3.10"

# switches that affect where to get the code
set :repo_url, "git@github.com:loudcloud-dev/ee_calculator.git"
set :keep_releases, 5
set :pty, true

# switches that affect bundler
# remove capistrano-bundler settings that do gem isolation
# since bundle config and rbenv-binstubs already do that
set :bundle_binstubs, nil # do not use shared bundle path between releases
set :bundle_path,     nil # trust bundle config to set the path
set :bundle_flags,    nil # be verbose, don't use deployment mode
set :rvm_map_bins, %w[ gem rake ruby rails bundle ]

set :precompile_env, "production"
set :assets_dir, "public/assets"
set :packs_dir, "public/packs"
set :rsync_cmd, "rsync -av --delete"
set :storage_dir, "storage/"

set :db_remote_clean, true
set :db_local_clean, true
set :db_remote_truncate_db, true

namespace :deploy do
  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

namespace :db do
  task :seed do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:seed"
        end
      end
    end
  end
end

namespace :service do
  task :restart do
    on roles(:app) do
      execute :sudo, "service #{fetch :service} stop"
      execute :sudo, "service #{fetch :service} start"
    end
  end

  task :start do
    on roles(:app) do
      execute :sudo, "service #{fetch :service} start"
    end
  end

  task :stop do
    on roles(:app) do
      execute :sudo, "service #{fetch :service} stop"
    end
  end
end

namespace :worker do
  task :restart do
    on roles(:app) do
      execute :sudo, "service #{fetch :worker_service} stop"
      execute :sudo, "service #{fetch :worker_service} start"
    end
  end

  task :start do
    on roles(:app) do
      execute :sudo, "service #{fetch :worker_service} start"
    end
  end

  task :stop do
    on roles(:app) do
      execute :sudo, "service #{fetch :worker_service} stop"
    end
  end
end

namespace :test do
  task :ruby_version do
    on roles(:app) do
      within release_path do
        execute :ruby, "-v"
      end
    end
  end

  task :exports do
    on roles(:app) do
      execute "export"
    end
  end
end

namespace :storage do
  task :download do
    on roles(:app) do
      puts "Storage Directory: #{fetch(:storage_dir)}"
      if Util.prompt("Are you sure you want to erase your local assets with server assets")
        servers = Capistrano::Configuration.env.send(:servers)
        server = servers.detect { |s| s.roles.include?(:app) }
        port = server.netssh_options[:port] || 22
        user = server.netssh_options[:user] || server.properties.fetch(:user)
        dirs = [ fetch(:storage_dir) ].flatten
        local_dirs = [ fetch(:storage_dir) ].flatten

        dirs.each_index do |idx|
          system("rsync -a --del -L -K -vv --progress --rsh='ssh -p #{port}' #{user}@#{server}:#{current_path}/#{dirs[idx]} #{local_dirs[idx]}")
        end
      end
    end
  end

  task :upload do
    on roles(:app) do
      servers = Capistrano::Configuration.env.send(:servers)
      server = servers.detect { |s| s.roles.include?(:app) }
      port = server.netssh_options[:port] || 22
      user = server.netssh_options[:user] || server.properties.fetch(:user)
      dirs = [ fetch(:storage_dir) ].flatten
      local_dirs = [ fetch(:storage_dir) ].flatten

      puts "Manually run this:"
      dirs.each_index do |idx|
        puts("rsync -av -L -K -vv --progress --rsh='ssh -p #{port}' #{local_dirs[idx]} #{user}@#{server}:#{current_path}/#{dirs[idx]}")
      end
    end
  end
end
