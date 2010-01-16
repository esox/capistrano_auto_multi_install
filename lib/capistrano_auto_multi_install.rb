require 'rubygems'
require 'i18n'
require 'yaml'

module CapistranoAutoMultiInstall
  I18n.load_path += Dir.glob(File.dirname(__FILE__)+"/locales/*.yml")
  I18n.default_locale = 'en'
end

require "capistrano_auto_multi_install/configure_web_server"
require "capistrano_auto_multi_install/configure_database"