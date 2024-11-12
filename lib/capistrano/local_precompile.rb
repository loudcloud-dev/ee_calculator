require 'capistrano/rails/assets'

namespace :load do
  task :defaults do
    set :precompile_env,   fetch(:rails_env) || 'production'
    set :assets_dir,       "public/assets"
    set :assets_cache_dir, "tmp/cache/assets/sprockets"
    set :packs_dir,        "public/packs"
    set :rsync_cmd,        "rsync -av --delete"
    set :assets_role,      "web"

    after "bundler:install", "deploy:assets:prepare"
    #before "deploy:assets:symlink", "deploy:assets:remove_manifest"
    after "deploy:assets:prepare", "deploy:assets:cleanup"
  end
end

namespace :deploy do
  # Clear existing task so we can replace it rather than "add" to it.
  Rake::Task["deploy:compile_assets"].clear

  namespace :assets do

    # desc "Remove manifest file from remote server"
    # task :remove_manifest do
    #   with rails_env: fetch(:assets_dir) do
    #     execute "rm -f #{shared_path}/#{shared_assets_prefix}/manifest*"
    #   end
    # end

    desc "Remove all local precompiled assets"
    task :cleanup do
      run_locally do
        with rails_env: fetch(:precompile_env) do
          execute "rm -rf", fetch(:assets_dir)
        end
      end
    end

    desc "Actually precompile the assets locally"
    task :prepare do
      run_locally do
        with rails_env: fetch(:precompile_env) do
          execute "bundle install"
          execute "yarn"
          execute "rm -rf #{fetch(:assets_cache_dir)}"
          execute "SECRET_KEY_BASE_DUMMY=1 rails assets:clobber assets:clean assets:precompile"
        end
      end

      on roles(fetch(:assets_role)) do |server|
        run_locally do
          execute "#{fetch(:rsync_cmd)} -e \"ssh -p #{server.port || 22}\" ./#{fetch(:assets_dir)}/ #{server.user}@#{server.hostname}:#{release_path}/#{fetch(:assets_dir)}/" if Dir.exist?(fetch(:assets_dir))
          execute "#{fetch(:rsync_cmd)} -e \"ssh -p #{server.port || 22}\" ./#{fetch(:packs_dir)}/ #{server.user}@#{server.hostname}:#{release_path}/#{fetch(:packs_dir)}/" if Dir.exist?(fetch(:packs_dir))
        end
      end
    end

    desc "Performs rsync to app servers"
    task :precompile do
      on roles(fetch(:assets_role)) do |server|
        run_locally do
          execute "#{fetch(:rsync_cmd)} -e \"ssh -p #{server.port || 22}\" ./#{fetch(:assets_dir)}/ #{server.user}@#{server.hostname}:#{release_path}/#{fetch(:assets_dir)}/" if Dir.exist?(fetch(:assets_dir))
          execute "#{fetch(:rsync_cmd)} -e \"ssh -p #{server.port || 22}\" ./#{fetch(:packs_dir)}/ #{server.user}@#{server.hostname}:#{release_path}/#{fetch(:packs_dir)}/" if Dir.exist?(fetch(:packs_dir))
        end
      end
    end
  end
end
