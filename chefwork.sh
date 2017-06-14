#!/bin/bash

set -e

OPTION=""
ORG=""
CHEF_RPM=""
ADMIN=""
CHEFSERVER=""
echo -n "Do you want to install or uninstall  the  Chef-Package? Enter "i" for install and "u" for uninstall --> "
read OPTION

if [[ "$OPTION" == "u" ]];then

echo -n "Enter the name of Chef-Package  to be Uninstalled.  --> "
read CHEF_RPM

sudo yum remove -y chefdk-$CHEF_RPM-1.el7.x86_64

elif [[ "$OPTION" == "i" ]];then
	
echo -n "Enter the name of Chef-Package  to be installed.  --> "
read CHEF_RPM
     if [[ -f "/opt/chefdk/version-manifest.txt"  &&  (($(head -n1 /opt/chefdk/version-manifest.txt|awk '{print $2}') == $CHEF_RPM)) ]];then
 echo "package $CHEF_RPM is already installed"
exit 0

else
echo -n "Enter CHEF-SERVER admin username  --> "
read ADMIN

echo -n "Enter URL of chef server  --> "
read CHEFSERVER


echo -n "Enter SHORTNAME of organization  used on  chef server  --> "
read ORG


DIR=/home/vagrant/chef-work

if [[ -d "$DIR" ]];then
  cd $DIR
else
mkdir $DIR
fi
cd $DIR

if [[ -f "chefdk-$CHEF_RPM-1.el7.x86_64.rpm" ]];then
echo "Package already available.Skipping Download and installing....."
sudo rpm -ivh "chefdk-$CHEF_RPM-1.el7.x86_64.rpm"
else
wget "https://packages.chef.io/files/stable/chefdk/1.3.43/el/7/chefdk-$CHEF_RPM-1.el7.x86_64.rpm"
sudo rpm -ivh "chefdk-$CHEF_RPM-1.el7.x86_64.rpm"
fi
echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
. ~/.bash_profile
cd ~
chef generate repo chef-repo
cd chef-repo
mkdir -p ~/chef-repo/.chef
#scp -pr root@chef-server:/etc/chef/"$ADMIN".pem ~/chef-repo/.chef/
#scp -pr root@chef-server:/etc/chef/$ORG-validator.pem ~/chef-repo/.chef/
cd .chef
cat << EOF > ~/chef-repo/.chef/knife.rb
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/$ADMIN.pem"
validation_client_name   "$ORG-validator"
validation_key           "#{current_dir}/$ORG-validator.pem"
chef_server_url          "https://$CHEFSERVER/organizations/$ORG"
syntax_check_cache_path  "#{ENV['HOME']}/.chef/syntaxcache"
cookbook_path            ["#{current_dir}/../cookbooks"]
EOF

exit 0
fi
fi


