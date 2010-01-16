require File.dirname(__FILE__)+"/handlers"
require File.dirname(__FILE__)+"/server"
class CapistranoAutoMultiInstall::ConfigureDatabase  < CapistranoAutoMultiInstall::Handlers
  attr_accessor :username,:password, :admin_username, :admin_password
  
  def initialize(*args)
    super *args
    @username = fetch(:mysql_user)
  end
  
  def check_or_create_database
    log 'Checking if '+fetch(:application)+'_production database exists'
    log "Creating it if it doesn't exist yet"
    
    @admin_username = fetch(:mysql_admin_name)
    @admin_password = fetch(:mysql_admin_password)
    @admin_password = '-p'+@admin_password unless @admin_password.empty?
    
    run_as_admin("'CREATE DATABASE IF NOT EXISTS `#{fetch(:application)}_production` \
DEFAULT CHARACTER SET utf8  \
DEFAULT COLLATE utf8_general_ci;'")
    
    log "Database done"
  end
  
  def check_or_create_user
    log 'Checking if '+fetch(:mysql_user)+' has already been created and granted correctly'
    log 'Errors messages reporting a missing user can be safely ignored'
    
    grants = capture_as_admin "'SHOW GRANTS FOR #{@username}@localhost;'", ";true;"
    
    ok = true
    
    required_grants = ["SELECT","INSERT","UPDATE","DELETE","CREATE","DROP", "INDEX", "LOCK TABLES", "ALTER", "CREATE VIEW"]
    if grants == "" # User is not present
      log 'User not present, creating him'
      ok = false
      # now let's create him
      @password = fetch(:mysql_user_password)
      run_as_admin "\"CREATE USER '#{@username}'@localhost IDENTIFIED BY '#{@password}'\""
    else
      log "User present, checking his rights"
      
      # First we've gotta filter the permissions by table.
      # here we wanna make sure he has the necessary rights on "application"_production
      grants = grants.split("\n").delete_if{ |grant| !(grant =~ Regexp.new(fetch(:application)+'_production'))}[0]
      
      # Are all "required_grants" present?
      required_grants.each do |grant|
        ok = grants =~ Regexp.new(grant) if ok
      end
    end
    # Ok = true => User exists and has the right rights on the right table
    if ok
      log 'Permissions are ok'
    else
      log 'Permissions are missing, adding them'
      flush = "&& mysqladmin flush-privileges -u #{@admin_username} #{@admin_password}"
      run_as_admin "\"GRANT "+required_grants.join(',')+" ON #{fetch(:application)}_production.* TO '#{@username}'@localhost\"", flush
    end
    log "Alright, now database and user are correctly set up"
    
    
    create_database_yml_file
  end
  
  def create_database_yml_file
    
    mysql_password = fetch(:mysql_user_password)
    mysql_user =  fetch(:mysql_user)
    
    conf = ERB.new(File.read(File.dirname(__FILE__)+"/database.yml.erb")).result(binding)
    run_with_power "mkdir -p #{fetch(:shared_path)}/db", fetch(:runner)
    run_with_power "mkdir -p #{fetch(:shared_path)}/config", fetch(:runner)
    put_with_power conf, "#{fetch(:shared_path)}/config/database.yml", fetch(:runner)
    
    syslink
  end
  
  def syslink
    run_with_power "ln -nfs #{fetch(:shared_path)}/config/database.yml #{fetch(:current_path)}/config/database.yml", fetch(:runner)
  end
  
  private
  
  def capture_as_admin command, string_to_add=''
    capture "echo #{command} | mysql -u #{@admin_username} #{@admin_password}"+string_to_add
  end
  
  def run_as_admin command, string_to_add=''
    run "echo #{command} | mysql -u #{@admin_username} #{@admin_password}"+string_to_add
  end
  
  def mysql_admin_password
    '-p'+@admin_username unless @admin_password.nil?
  end
  
end
