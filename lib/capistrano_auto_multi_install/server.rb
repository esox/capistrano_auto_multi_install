class CapistranoAutoMultiInstall::Server < CapistranoAutoMultiInstall::Handlers
  attr_accessor :name, :conf , :conf_dir
end

class CapistranoAutoMultiInstall::Passenger < CapistranoAutoMultiInstall::Server
  
  attr_accessor :tmp
  
  def initialize capistrano, options
    @tmp = fetch(:deploy_to)+'/../passenger_tmp/'+fetch(:application)
    super capistrano, options
  end
  
  def generate_conf_files
    # Intanciate some locals which will be used in erb file
    document_root = fetch(:deploy_to)+'/public'
    server_name = name
    passenger_tmp = tmp
    
    @conf = ERB.new(File.read(File.dirname(__FILE__)+"/passenger.conf.erb")).result(binding)
  end
  
  def write
    # If the user we use to connect to the server is not the same one running the application,
    # namely web_user, then we've gotta use "with_power" methods
    if exists?(:runner) && fetch(:runner) != fetch(:user)
      run_with_power "mkdir -p "+tmp, fetch(:web_user)
      put_with_power conf, conf_dir+'/'+fetch(:application)+'.conf', fetch(:runner)
    else
      run  "mkdir -p "+tmp
      put conf, conf_dir+'/'+fetch(:application)+'.conf'
    end
  end
end


class CapistranoAutoMultiInstall::MongrelCluster < CapistranoAutoMultiInstall::Server
  attr_accessor :port, :number_instances, :local_conf_dir
  
  def initialize *args
    super *args
    @DEFAULT_LOCAL_CONF_DIR=fetch(:shared_path)+'/config'
  end
  
  def generate_conf_files    
    base_directory = fetch(:deploy_to)+'/current'
    web_user = (exists?(:web_user))?fetch(:web_user):fetch(:user)
    @conf = ERB.new(File.read(File.dirname(__FILE__)+"/mongrel.conf.erb")).result(binding)
  end
  
  def write
    if local_conf_dir == '/config'
      put conf,@DEFAULT_LOCAL_CONF_DIR+'/mongrel_cluster.yml'
    else
      if exists?(:runner) && fetch(:runner) != fetch(:user)
        put_with_power conf, local_conf_dir+'/'+fetch(:application)+'.conf', fetch(:runner)
      else
        put conf, local_conf_dir+'/'+fetch(:application)+'.conf'
      end
    end
  end
  
end

class CapistranoAutoMultiInstall::Mongrel < CapistranoAutoMultiInstall::MongrelCluster
  def write
    if local_conf_dir == @DEFAULT_LOCAL_CONF_DIR
      put conf,@DEFAULT_LOCAL_CONF_DIR+'/mongrel.yml'
    else
      if exists?(:runner) && fetch(:runner) != fetch(:user)
        put_with_power conf, local_conf_dir+'/'+fetch(:application)+'.conf', fetch(:runner)
      else
        put conf, local_conf_dir+'/'+fetch(:application)+'.conf'
      end
    end
  end
  
  private 
  def number_of_instances
    1
  end
end