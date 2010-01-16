class CapistranoAutoMultiInstall::Handlers
  @@conf_file = nil
  
  def logger
    @logger
  end
  
  def capistrano_instance
    @@capistrano
  end
  
  def initialize capistrano, options
    @@capistrano = capistrano
    @logger = options[:logger]
  end
  
  def run_with_power command, as_user=nil
    if fetch(:use_sudo)
      log "Running a command with sudo"
      if as_user
        sudo "su -c '"+command+"' "+as_user
      else
        sudo command
      end
      # elsif exists?(:use_su) && fetch(:use_su)
      #   log "Running a command with su"
      #   command = "su -c '#{command}'"
    else
      log "Then trying to proceed as a normal user"
    end
  end
  
  
  def run command
    @@capistrano.run command 
  end
  
  def sudo *command
    @@capistrano.sudo  *command  
  end
  
  def capture command
    @@capistrano.capture command
  end
  
  def put *command
    @@capistrano.put *command
  end
  
  def put_with_power *command
    log "Putting with power"
    content = command.delete_at 0
    destination = command.delete_at 0
    run_as = nil
    
    if command.last.is_a? String
      run_as = command.last
      command.delete(run_as)
    end
    
    
    put content, destination, ((command[0].is_a? Hash)?command[0]:{})
    
    unless run_as.nil?
      log "Changing owner"
      run_with_power "chown -R #{run_as} #{destination}"
    end
  end
  
  def fetch attr
    @@capistrano.fetch attr
  end
  
  def exists? attr
    @@capistrano.exists? attr
  end
  
  
  protected
  def get_in_conf_file(key)
    deploy_conf_file = ''
    if exists? :deploy_conf_file
      deploy_conf_file = fetch(:deploy_conf_file)
    else
      @@conf_file = Hash.new
    end
    @@conf_file = YAML::load(File.open()) if @@conf_file.nil?
    @@conf_file[key.to_s]
  end
  
  
  private
  @logger = nil
  
  def err message
    @logger.info message
  end
  
  def log message
    @logger.info message
  end  
end