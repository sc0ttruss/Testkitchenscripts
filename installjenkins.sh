#!/bin/bash
################################
#
#   Install Jenkins using Testkitchen
#
################################
# setup the default locations for the install
# and the default OS
#
COOKBOOKDIR=$HOME/Source/Testkitchen/Jenkins
OS="centos-6.5"
OSNODOTS=${OS//\./} # replace the "dot" in the "OS" variable
COOKBOOK="jenkins"
# destroy old instances that were lying around
cd $COOKBOOKDIR
kitchen destroy $COOKBOOK-$OSNODOTS
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
#
# check if running vmware_workstation or virtualbox,
# virtualbox is assumed the default
# 
# Hint, set this variable on the command line before you 
# run this script if you want vmware_workstation
#
case $VAGRANT_DEFAULT_PROVIDER in
  vmware_workstation|vmware_fusion)
    CPUVAR=numvcpus    # name of cpu for vmware vagrant
    ;;
  virtualbox)
    CPUVAR=cpus        # name of cpu for virtualbox vagrant
    ;;
  *)
    CPUVAR=cpus        # name of cpu for virtualbox, default value
    VAGRANT_DEFAULT_PROVIDER=virtualbox # default to virtualbox if environment variable not set.
    echo "VAGRANT_DEFAULT_PROVIDER, not set, setting to virtualbox as default, for this script"
    ;;
esac

tee $COOKBOOKDIR/.kitchen.yml >/dev/null <<EOF
# setup of testkitchen to allow install of jenkins via a chef script
# allow debug of kitchen scripts
# export KITCHEN_LOG='DEBUG'

driver:
  name: vagrant

driver_config:
  customize:
    memory: 4048
    $CPUVAR: 2

provisioner:
  name: chef_solo

platforms:
  - name: $OS

suites:
  - name: $COOKBOOK
    run_list:
      - recipe[java::oracle]
      - recipe[jenkins::master]
    attributes:
      java:
        oracle:
          accept_oracle_download_terms: true
        install_flavor: oracle
EOF

kitchen list
kitchen create $COOKBOOK-$OSNODOTS
kitchen converge $COOKBOOK-$OSNODOTS

