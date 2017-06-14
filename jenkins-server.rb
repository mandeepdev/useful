#
# Cookbook:: pipeline
# Recipe:: jenkins-server
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#

src_filename = 'jenkins-2.9-1.1.noarch.rpm'
src_filepath = "#{Chef::Config[:file_cache_path]}/#{src_filename}"
src_new = '2.9-1'
src_old = '2.7-1'
remote_file "#{src_filepath}" do
        source "https://pkg.jenkins.io/redhat/#{src_filename}"	
end


package  'java-1.8.0-openjdk' do

	action :install
end


execute 'install_jenkins' do
	cwd ::File.dirname(src_filepath)
	command <<-EOH
	sudo yum remove -y jenkins-2*
	sudo rpm --import http://pkg.jenkins.io/redhat-stable/jenkins.io.key	  
	sudo yum install -y  #{src_filename}
	sudo touch /var/lib/jenkins/#{src_new}
	sudo rm -rf /var/lib/jenkins/#{src_old}
	  EOH
not_if {File.exist?("/var/lib/jenkins/#{src_new})")} end


service 'jenkins' do
	action [:enable , :start]
end
