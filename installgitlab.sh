#!/bin/bash
################################
#
#   Install Automate from Chef using Testkitchen
#
################################
# setup the default locations for the install
# and the default OS
#
COOKBOOKDIR=$HOME/Source/Demos/Wip/Gitlab
# destroy old instances that were lying around
cd $COOKBOOKDIR
echo "now in Automate directory"
kitchen destroy
cd ../
## rm -Rf $COOKBOOKDIR
mkdir -p $COOKBOOKDIR
cd $COOKBOOKDIR
## mkdir -p  ~/chef-kits/chef
cd  ~/chef-kits/chef
wget -N https://packages.gitlab.com/gitlab/gitlab-ce/packages/el/7/gitlab-ce-8.12.7-ce.0.el7.x86_64.rpm/download
cd $COOKBOOKDIR/
# download the automate cookbook
git clone https://github.com/sc0ttruss/gitlab.git
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
# echo `pwd`
## cd $COOKBOOKDIR/delivery_push_jobs
## kitchen list
## kitchen converge acceptance01 &
## kitchen converge union01 &
## kitchen converge rehearsal01 &
## kitchen converge delivered01 &
cd $COOKBOOKDIR/gitlab
echo "now in gitlab directory"
kitchen list
kitchen converge
kitchen list
