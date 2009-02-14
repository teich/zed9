set :user, 'teich'  # Your dreamhost account's username
set :domain, 'zednine.com'  # Dreamhost servername where your account is located 
set :project, 'zed9'  # Your application as its called in the repository
set :application, 'zednine.com'  # Your app's location (domain or sub-domain name as setup in panel)
set :applicationdir, "/home/#{user}/#{application}"  # The standard Dreamhost setup

# version control config
set :repository, "ssh://z9git@zed9.org/~/git/zed9.git"
set :scm, "git"
set :user, "teich"
set :branch, "master"

# roles (servers)
role :web, domain
role :app, domain
role :db,  domain, :primary => true

# deploy config
set :deploy_to, applicationdir
set :deploy_via, :export

# additional settings
default_run_options[:pty] = true 
#ssh_options[:keys] = %w(/Path/To/id_rsa)            # If you are using ssh_keys
set :chmod755, "app config db lib public vendor script script/* public/disp*"
set :use_sudo, false

#############################################################
#	Passenger
#############################################################

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

after :deploy, "passenger:restart"