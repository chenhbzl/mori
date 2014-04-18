# config valid only for Capistrano 3.1
lock '3.2.0'

set :application, 'my_app_name'
set :repo_url, 'git@github.com:easyhappy/mori.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :branch, :test_capistrano_deploy

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/home/ubuntu/Document/mori"
set :rails_env, :production
set :deploy_user, :ubuntu
# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      execute :rails, "s -p 8080"
    end
  end

  task :start do
    on roles(:web), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
      within '/home/ubuntu/Document/mori' do
        %x('RAILS_ENV=development bundle exec rails "s -p 8080"')
      end
    end
  end

  after :publishing, :start

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
