#!/bin/bash
################################
#
#   Install Chef-server using Testkitchen
#
################################
# setup the default locations for the install
# and the default OS
#
COOKBOOKDIR=~/Source/Testkitchen/Chef-server
OS="centos-6.5"
OSnodots="centos-65"
COOKBOOK="Chef-server"
# destroy old instances that were lying around
#
cd $COOKBOOKDIR
kitchen destroy $COOKBOOK-$OSnodots
cd -
rm -Rf $COOKBOOKDIR
mkdir -p $COOKBOOKDIR/cookbooks
cd $COOKBOOKDIR/cookbooks 
# download the Chef-server cookbook
#
git clone https://github.com/opscode-cookbooks/chef-server
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
#
# create the config file for test kitchen
#
tee $COOKBOOKDIR/.kitchen.yml >/dev/null <<EOF
# setup of testkitchen to allow install of Chef-server via a chef script
# allow debug of kitchen scripts
# export KITCHEN_LOG='DEBUG'

driver:
  name: vagrant

# replace "$USER" with your own username/id 

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
      - recipe[chef-server::default]
    attributes:
EOF
kitchen list
kitchen create $COOKBOOK-$OSnodots
kitchen converge $COOKBOOK-$OSnodots



#License and Authors
#===================
#
#Email:: <copyright@inetmedia.co.uk>
#Author:: Scott Russell
#
#Copyright:: 2014, Scott Russell
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#<http://www.apache.org/licenses/LICENSE-2.0>
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
