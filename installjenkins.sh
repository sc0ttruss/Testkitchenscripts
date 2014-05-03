#/bin/bash
################################
#
#   Install Jenkins using Testkitchen
#
################################
# setup the default locations for the install
# and the default OS
#
COOKBOOKDIR=~/Source/Testkitchen/Jenkins
OS="centos-6.5"
OSnodots="centos-65"
COOKBOOK="jenkins"
# destroy old instances that were lying around
cd $COOKBOOKDIR
kitchen destroy $COOKBOOK-$OSnodots
cd -
rm -Rf $COOKBOOKDIR
mkdir -p $COOKBOOKDIR/cookbooks
cd $COOKBOOKDIR/cookbooks
git clone https://github.com/opscode-cookbooks/jenkins.git
git clone https://github.com/opscode-cookbooks/apt.git
git clone https://github.com/opscode-cookbooks/runit.git
git clone https://github.com/opscode-cookbooks/yum.git
git clone https://github.com/opscode-cookbooks/build-essential.git
git clone https://github.com/opscode-cookbooks/yum-epel.git
git clone https://github.com/opscode-cookbooks/java.git
cd ..
tee $COOKBOOKDIR/.kitchen.yml >/dev/null <<EOF
# setup of testkitchen to allow install of jenkins via a chef script
# allow debug of kitchen scripts
# export KITCHEN_LOG='DEBUG'

driver:
  name: vagrant

# replace "$HOME" with another location if you
# want to have it in a different base directory 

driver_config:
  #synced_folders: [  [ "/$HOME/Source/Chef/Oraclebin","/opt/applications/chef/Oraclebin", "create: false, disabled: false" ] ]
  customize:
    memory: 4048
    numvcpus: 2

provisioner:
  name: chef_solo

platforms:
  - name: $OS

suites:
  - name: $COOKBOOK
    data_bag_path: "/home/$USER/Source/Testkitchen/Oracle/data_bags"
    role_path: "/home/$USER/Source/Testkitchen/Oracle/roles"
    encrypted_data_bag_secret_key_path: "/home/$USER/.gnupg/password.txt"
    run_list:
      - recipe[java::oracle]
      - recipe[jenkins::master]
      #- role[oracle_full_test]
      #- role[oracle_createdb]
    #attributes:
    attributes:
      java:
        oracle:
          accept_oracle_download_terms: true
        install_flavor: oracle
EOF

kitchen list
kitchen create $COOKBOOK-$OSnodots
kitchen converge $COOKBOOK-$OSnodots

