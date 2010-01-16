require 'rubygems'
spec = Gem::Specification.new do |s|

s.name = "capistrano_auto_multi_install"
s.version =  "1.0.1"
s.author = "Stefano Grioni"
s.email = "stefano_dot_grioni_at.gmail_dot_com"
s.platform = Gem::Platform::RUBY
s.summary = "A set of tasks helping you to deploy with capistrano"
files = Dir.glob("{tests,lib,tasks,doc}/**/*")
s.files = files.delete_if do |item|
	item.include?(".svn") || item.include?("rdoc") 
end
s.require_path = "lib"
s.has_rdoc = false
s.add_dependency("capistrano",">=2.0.0")
s.add_dependency("i18n")
s.add_dependency("yamler")
end
