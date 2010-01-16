require File.dirname(__FILE__)+"/handlers"
require File.dirname(__FILE__)+"/server"
class CapistranoAutoMultiInstall::ConfigureWebServer < CapistranoAutoMultiInstall::Handlers
  attr_accessor :server, :server_type, :server_name, :server_conf_dir
  
  def generate_conf_files
    log I18n.t :apache_only_supported
    
    @server_name = fetch(:application_url)
    @server_conf_dir = fetch(:apache_conf_directory)
    @server_type = fetch(:passenger_or_mongrel)
    
    if server_type == 'passenger'
      @server = CapistranoAutoMultiInstall::Passenger.new(capistrano_instance,:logger=>logger)
    else
      server_local_conf = fetch(:mongrel_local_conf)
      @server.port = fetch(:mongrel_port)
      if fetch(:mongrel_cluster) == "no"
        log I18n.t :single_mongrel_selected
        @server = CapistranoAutoMultiInstall::Mongrel.new(capistrano_instance,:logger=>logger)
      else
        log I18n.t :cluster_mongrel_selected
        @server = CapistranoAutoMultiInstall::MongrelCluster.new(capistrano_instance,:logger=>logger)
        @server.number_instances = fetch(:number_of_mongrel_instance)
      end
      @server.local_conf_dir = server_local_conf
    end
    @server.conf_dir = @server_conf_dir
    @server.name = @server_name
    @server.generate_conf_files
  end
  
  def write
    @server.write
  end
end