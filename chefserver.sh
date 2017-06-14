#!/bin/bash 


OPTION=""
CHEF_RPM=""
FIRST_NAME=""
LAST_NAME=""
EMAIL=""
PASSWORD=""
ORG_SHORT=""
ORG_FULL=""

echo -n "Do you want to install or uninstall  the  Chef-Package? Enter "i" for install and "u" for uninstall --> "
read OPTION

if [[ "$OPTION" == "u" ]];then

echo -n "Enter the name of Chef-Package  to be Uninstalled.  --> "
read CHEF_RPM

sudo yum remove -y chef-server-core-$CHEF_RPM-1.el7.x86_64

elif [[ "$OPTION" == "i" ]];then
	
echo -n "Enter the name of Chef-Package  to be installed.  --> "
read CHEF_RPM
     if [[ -f "/opt/opscode/version-manifest.txt"  &&  (($(head -n1 /opt/opscode/version-manifest.txt|awk '{print $2}') == $CHEF_RPM)) ]];then
 echo "package $CHEF_RPM is already installed"
exit 0

else

echo -n "Enter First name of Chef admin  --> "
read FIRST_NAME

echo -n "Enter Last name of Chef admin  --> "
read LAST_NAME

echo -n "Enter email of Chef admin  --> "
read EMAIL

echo -n "Enter Password for Chef admin  --> "
read PASSWORD

echo -n "Enter  short name for your organization --> "
read ORG_SHORT

echo -n "Enter Full  name of your organization  --> "
read ORG_FULL


DIR=chef-server

if [[ -d "$DIR" ]];then
  cd $DIR
else
mkdir $DIR
fi
cd $DIR

wget "https://packages.chef.io/files/stable/chef-server/12.14.0/el/7/chef-server-core-$CHEF_RPM-1.el7.x86_64.rpm"
sudo rpm -ivh chef-server-core-"$CHEF_RPM"-1.el7.x86_64.rpm 
sudo chef-server-ctl reconfigure
sudo chef-server-ctl user-create admin $FIRST_NAME $LAST_NAME $EMAIL $PASSWORD -f /etc/chef/admin.pem
sudo chef-server-ctl org-create $ORG_SHORT "$ORG_FULL" --association_user admin -f /etc/chef/$ORG_SHORT-validator.pem
sudo systemctl status firewalld
if (( $? != 0 ));then
echo "Enable firewalld service"
elif (( $? == 0));then
sudo firewall-cmd --permanent --zone public --add-service http
sudo firewall-cmd --permanent --zone public --add-service https
sudo firewall-cmd --reload
exit 0
fi
fi
fi
