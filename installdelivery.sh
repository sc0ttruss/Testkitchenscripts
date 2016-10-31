#!/bin/bash
################################
#
#   Install Jenkins using Testkitchen
#
################################
# setup the default locations for the install
# and the default OS
#
COOKBOOKDIR=$HOME/Source/Demos/Wip/Westpac/Delivery
# destroy old instances that were lying around
cd $COOKBOOKDIR/delivery_chef
echo "now in delivery_chef directory"
kitchen destroy
cd $COOKBOOKDIR/delivery_supermarket
kitchen destroy
cd $COOKBOOKDIR/automate
kitchen destroy
# cd $COOKBOOKDIR/delivery_builder
# kitchen destroy
cd $COOKBOOKDIR/delivery_push_jobs
kitchen destroy
cd ../../
## rm -Rf $COOKBOOKDIR
mkdir -p $COOKBOOKDIR
cd $COOKBOOKDIR
## mkdir -p  ~/chef-kits/chef
cd  ~/chef-kits/chef
wget -N https://packages.chef.io/stable/el/6/opscode-push-jobs-server-1.1.6-1.x86_64.rpm --no-check-certificate
wget -N https://packages.chef.io/stable/el/7/opscode-analytics-1.5.0-1.el7.x86_64.rpm --no-check-certificate
wget -N https://packages.chef.io/stable/el/7/opscode-reporting-1.6.4-1.el7.x86_64.rpm --no-check-certificate
wget -N https://packages.chef.io/stable/el/7/chef-server-core-12.9.1-1.el7.x86_64.rpm --no-check-certificate
# wget -N https://packages.chef.io/stable/el/7/push-jobs-client-1.3.4-1.el7.x86_64.rpm --no-check-certificate
wget -N https://packages.chef.io/stable/el/7/push-jobs-client-2.1.1-1.el7.x86_64.rpm --no-check-certificate
wget -N https://packages.chef.io/stable/el/7/chefdk-0.19.6-1.el7.x86_64.rpm --no-check-certificate
wget -N https://packages.chef.io/stable/el/7/delivery-0.5.432-1.el7.x86_64.rpm --no-check-certificate
wget -N https://packages.chef.io/stable/el/7/chef-manage-2.4.3-1.el7.x86_64.rpm --no-check-certificate
wget -N https://packages.chef.io/stable/el/7/chef-compliance-1.6.8-1.el7.x86_64.rpm --no-check-certificate
# wget -N https://packages.chef.io/stable/el/7/chef-12.11.18-1.el7.x86_64.rpm --no-check-certificate
# wget -N https://packagecloud.io/imeyer/runit/packages/el/7/runit-2.1.2-3.el7.centos.x86_64.rpm/download --no-check-certificate
## mv download runit-2.1.2-3.el7.centos.x86_64.rpm
cd $COOKBOOKDIR/
## # download all the delivery repositories
git clone https://github.com/sc0ttruss/delivery_push_jobs.git
git clone https://github.com/sc0ttruss/delivery_builder.git
git clone https://github.com/sc0ttruss/delivery_build.git
#git clone https://github.com/sc0ttruss/delivery_server.git
git clone https://github.com/sc0ttruss/automate.git
git clone https://github.com/sc0ttruss/delivery_chef.git
git clone https://github.com/sc0ttruss/delivery_compliance.git
git clone https://github.com/sc0ttruss/delivery_supermarket.git
git clone https://github.com/sc0ttruss/delivery_workstation.git
git clone https://github.com/sc0ttruss/push-jobs.git
git clone https://github.com/sc0ttruss/demo.git
git clone https://github.com/chef-cookbooks/pcb.git
git clone https://github.com/chef-cookbooks/delivery-truck
git clone https://github.com/chef-cookbooks/delivery-base
git clone https://github.com/chef-cookbooks/delivery_build
git clone https://github.com/chef-cookbooks/delivery-sugar
git clone https://github.com/chef-cookbooks/chef_handler.git 
git clone https://github.com/chef-cookbooks/compat_resource.git
git clone https://github.com/chef-cookbooks/audit.git
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
cd $COOKBOOKDIR/delivery_chef
echo "now in delivery_chef directory"
kitchen list
kitchen converge
kitchen list
cd $COOKBOOKDIR/delivery_supermarket
kitchen list
kitchen converge
kitchen list
cd $COOKBOOKDIR/automate
kitchen list
kitchen converge
kitchen list
cd $COOKBOOKDIR/delivery_compliance
kitchen list
kitchen converge
kitchen list
cd $COOKBOOKDIR/delivery_builder
kitchen list]k
kitchen converge
kitchen list
# create the environment nodes at the end
# cd $COOKBOOKDIR/delivery_push_jobs
# kitchen list
# kitchen converge
# kitchen list
echo "Looks like we are complete, now go follow the manual instructions"
# Manual step, need to stop here
echo 'Login to supermarket as chef user srv-delivery, and press yes button'
echo 'Authorization Required, Authorize supermarket to use your Chef account?'
echo "and accept the app shareing with supermarket "
echo "login to chef server and run ( as root )the command between the "---" in the file
echo "~/chef-kits/chef/compliancechefintegration.txt on the chef server, making
echo "sure to save the output and run that command output on the automate server"
echo "note: only nodes under management by Chef that successfully run `audit::default`
echo "will show up in Chef Compliance"
read -s -n 1 -p "Manual step 1. Do, above step, then Press any key to continue.."
mkdir $COOKBOOKDIR/workspace
cd $COOKBOOKDIR/workspace
#cp -Ra $COOKBOOKDIR/delivery_workstation/ ./  ( delete this line, probably )
rsync -av --progress $COOKBOOKDIR/delivery_workstation/ $COOKBOOKDIR/workspace --exclude .git
# add the chef server cert to the local trusted_certs directory
knife ssl fetch https://chef.myorg.chefdemo.net
knife ssl fetch https://supermarket.myorg.chefdemo.net
# Let's check that was successfull
knife ssl check https://chef.myorg.chefdemo.net
knife ssl check https://supermarket.myorg.chefdemo.net
# add the supermarket search to the local chefdk
# note if you ugrade chefdk, this has to be upgraded too
echo 'you probably need root password to run the next command'
echo 'but dont worry the OS will prompt you'
sudo bash -c "cat ./.chef/trusted_certs/*.crt >> /opt/chefdk/embedded/ssl/certs/cacert.pem"
# upload the delivery_nodes emvironment, plus
# union, rehearsal and delivered0
# Acceptance will be created on first run by delivery
knife upload environment ./environments/delivery_nodes.json
knife upload environment ./environments/union.json
knife upload environment ./environments/rehearsal.json
knife upload environment ./environments/delivered.json
#  Add the cookbooks to the local supermarket
# server that you just built above
# note you need to have added the certs to the local
# workspace to make this successfull
knife supermarket share -o $COOKBOOKDIR 'delivery_supermarket'
knife supermarket share -o $COOKBOOKDIR 'automate'
knife supermarket share -o $COOKBOOKDIR 'delivery_build'
# knife supermarket share -o $COOKBOOKDIR 'delivery_builder'
knife supermarket share -o $COOKBOOKDIR 'delivery_push_jobs'
knife supermarket share -o $COOKBOOKDIR 'delivery_chef'
knife supermarket share -o $COOKBOOKDIR 'delivery_compliance'
knife supermarket share -o $COOKBOOKDIR 'push-jobs'
knife supermarket share -o $COOKBOOKDIR 'demo'
knife supermarket share -o $COOKBOOKDIR 'pcb'
knife supermarket share -o $COOKBOOKDIR 'delivery-truck'
knife supermarket share -o $COOKBOOKDIR 'delivery-base'
knife supermarket share -o $COOKBOOKDIR 'delivery_build'
knife supermarket share -o $COOKBOOKDIR 'delivery-sugar'
knife supermarket share -o $COOKBOOKDIR 'audit'
knife supermarket share -o $COOKBOOKDIR 'compat_resource'
knife supermarket share -o $COOKBOOKDIR 'chef_handler'
# this secion commmented out as takes too many
# boilerplate cookbooks that are not required for redhat
# kept here as a reminder of what might be for other OS'S
#  # install all dependent cookbooks to chef server
#  berks install -b  $COOKBOOKDIR/delivery_push_jobs/Berksfile
#  berks install -b  $COOKBOOKDIR/delivery_chef/Berksfile
#  berks install -b  $COOKBOOKDIR/delivery_supermarket/Berksfile
#  berks install -b  $COOKBOOKDIR/automate/Berksfile
#  berks install -b  $COOKBOOKDIR/delivery_builder/Berksfile
#  berks install -b  $COOKBOOKDIR/delivery_build/Berksfile
#  berks install -b  $COOKBOOKDIR/delivery_push_jobs/Berksfile
#  berks install -b  $COOKBOOKDIR/demo/Berksfile
#  # there is no berksfile for this pcb.
#  # berks install -b  $COOKBOOKDIR/pcb/Berksfile
#  berks install -b  $COOKBOOKDIR/delivery-truck/Berksfile
#  berks install -b  $COOKBOOKDIR/delivery-base/Berksfile
#  berks install -b  $COOKBOOKDIR/delivery_build/Berksfile
#  berks install -b  $COOKBOOKDIR/delivery-sugar/Berksfile
#  # upload all cookbooks to chef server
#  berks upload -b  $COOKBOOKDIR/delivery_push_jobs/Berksfile
#  berks upload -b  $COOKBOOKDIR/delivery_chef/Berksfile
#  berks upload -b  $COOKBOOKDIR/delivery_supermarket/Berksfile
#  berks upload -b  $COOKBOOKDIR/automate/Berksfile
#  berks upload -b  $COOKBOOKDIR/delivery_builder/Berksfile
#  berks upload -b  $COOKBOOKDIR/delivery_build/Berksfile
#  berks upload -b  $COOKBOOKDIR/delivery_push_jobs/Berksfile
#  berks upload -b  $COOKBOOKDIR/demo/Berksfile
#  # berks upload -b  $COOKBOOKDIR/pcb/Berksfile
#  # ok no berksfile so try this instead.
#  knife cookbook upload --cookbook-path ../../Delivery pcb
#  berks upload -b  $COOKBOOKDIR/delivery-truck/Berksfile
#  berks upload -b  $COOKBOOKDIR/delivery-base/Berksfile
#  berks upload -b  $COOKBOOKDIR/delivery_build/Berksfile
#  berks upload -b  $COOKBOOKDIR/delivery-sugar/Berksfile


# Required once the chef server is up and running
# knife cookbook upload --cookbook-path $COOKBOOKDIR/automate automate
# knife cookbook upload --cookbook-path $COOKBOOKDIR/delivery_supermarket delivery_supermarket
# knife cookbook upload --cookbook-path $COOKBOOKDIR/supermarket-omnibus-cookbook

# for the moment, concentrate on building delivery only offline/without internet accesss
# upload the build and builder cookbooks to chef server
knife cookbook upload --cookbook-path $COOKBOOKDIR/ delivery_build
# knife cookbook upload --cookbook-path $COOKBOOKDIR/delivery_builder delivery_builder
knife cookbook upload --cookbook-path $COOKBOOKDIR/ push-jobs
knife cookbook upload --cookbook-path $COOKBOOKDIR/ delivery_push_jobs
knife cookbook upload --cookbook-path $COOKBOOKDIR/ demo
# need to modify these cookbooks if you want to install
# without internet access
knife cookbook upload --cookbook-path $COOKBOOKDIR/ pcb
knife cookbook upload --cookbook-path $COOKBOOKDIR/ delivery-base
knife cookbook upload --cookbook-path $COOKBOOKDIR/ delivery_build
knife cookbook upload --cookbook-path $COOKBOOKDIR/ delivery-sugar
knife cookbook upload --cookbook-path $COOKBOOKDIR/ delivery-truck
# for compliance need to have the audit cookbook in chef server
knife cookbook upload --cookbook-path $COOKBOOKDIR/ compat_resource
knife cookbook upload --cookbook-path $COOKBOOKDIR/ chef_handler
knife cookbook upload --cookbook-path $COOKBOOKDIR/ audit
## echo 'bootsttap builder1 node ( note you might prefer x3 of these nodes )'
## knife bootstrap builder1.myorg.chefdemo.net --sudo -x vagrant -P vagrant -N "builder1.myorg.chefdemo.net" -E "delivery_nodes" -r 'recipe[delivery_builder::default]'
## echo 'before the next step, you might have to remove the "delivery server"'
## echo ' from your ~/.ssh/knownhosts file, if it already exists..'
# Bootstrap the environment nodes
# mote the acceptance environment has to exist for this bootstrap to work,
# so do the following in delivery.
echo 'Login to the console, as "admin" user here https://automate.myorg.chefdemo.net'
echo 'password is in the ~/chef-kits/chef/passwords.txt file ( from chef server )'
echo 'add your public key to the delivery user'
echo 'and select all the roles  admin, committer, reviewer, shipper, observer'
echo 'if needed, create keys with "ssh-keygen -t rsa -b 4096 -C automate@myorg.chefdemo.net -V +1024w1d"'
echo 'add a new org called myorg or whatever you called your org'
echo 'logout and log back in again as delivery user'
echo 'Login to the console, as "srv-delivery" user here https://automate.myorg.chefdemo.net'
echo 'password is in the ~/chef-kits/chef/deliverypassword.txt file ( from delivery server )'
echo 'just to validate the user and pasword are operational'
echo 'check out the diagram here https://www.lucidchart.com/documents/edit/0a0c86f4-abe9-47ba-8234-ba2db866023a'
echo 'create an organisation called 'myorg', but DO NOT create the project 'demo''
echo 'https://automate.myorg.chefdemo.net/e/myorg/#/organizations'
read -s -n 1 -p "Manual step 2. Do, above steps, then Press any key to continue.."
# accept the rsa key for identity of host on the workstation
ssh -l srv-delivery@myorg -p 8989 automate.myorg.chefdemo.net
# think we have to run this twice, once to add, then once to connect
ssh -l srv-delivery@myorg -p 8989 automate.myorg.chefdemo.net
# output should be similar to the following:-
# The authenticity of host '[automate.myorg.chefdemo.net]:8989 ([192.168.56.46]:8989)' can't be established.
# RSA key fingerprint is 64:b5:7e:df:dc:1e:45:80:b1:91:87:ad:f6:c3:db:99.
# Are you sure you want to continue connecting (yes/no)? yes
# Warning: Permanently added '[automate.myorg.chefdemo.net]:8989,[192.168.56.46]:8989' (RSA) to the list of known hosts.
# Connection closed by 192.168.56.46
# scott@vertex:~/Vm/Source/Demos/Wip/Westpac/Delivery/delivery_workstation$ ssh -l delivery@myorg -p 8989 automate.myorg.chefdemo.net
# channel 0: protocol error: close rcvd twice
# Hi delivery@myorg! You've successfully authenticated, but Chef Delivery does not provide shell access.
#               Connection to automate.myorg.chefdemo.net closed.

mkdir $COOKBOOKDIR/workspace/demo
cd $COOKBOOKDIR/workspace/demo
git init .
delivery setup --ent=myorg --org=myorg --user=srv-delivery --server=automate.myorg.chefdemo.net
echo "# demo " >> README.md
git add README.md
git commit -m "Initial commit"
echo 'note:  the next password is from your deliverypassword.txt'
echo 'which is on the delivery server /etc/delvier/deliverypassword.txt'
echo 'or locally in ~/chef-kits/chef, if you are running testkitchen'
delivery token
# Run delivery init, which will create an empty build cookbook for
# you (with an empty set of phase recipes), add the cookbook to your project,
# create the new pipeline and submit the project to Delivery for review:
delivery init
echo 'manual step 3., go work the pipeline in the browser ( review and deliver buttons ), then come back here.'
read -s -n 1 -p "4. Do, above steps, then Press any key to continue.."
##  old way, no longer supported
## delivery clone demo --ent=myorg --org=myorg --user=delivery --server=automate.myorg.chefdemo.net
## cd demo
## # Create a project configuration file:
## delivery setup --ent=myorg --org=myorg --user=delivery --server=automate.myorg.chefdemo.net
## # Obtain a Delivery API token (you'll be prompted for your password here):
## vi readme
## git add .
## git commit -m "try2"
## delivery token
# note:  this is the password from your deliverypassword.txt file from
# the deliery server
# Run delivery init, which will create an empty build cookbook for
# you (with an empty set of phase recipes), add the cookbook to your project,
# create the new pipeline and submit the project to Delivery for review:
##delivery init
# copy in the demo cookbook downloaded above, everything except the .git directory

echo "now let's add some environments to the pipeline "
cd $COOKBOOKDIR/delivery_push_jobs
kitchen list
kitchen converge acceptance01 &
kitchen converge union01 &
kitchen converge rehearsal01 &
kitchen converge delivered01 &
# once a project has ran through once, do
cd $COOKBOOKDIR/workspace/demo
git pull --prune
git checkout -b firstry
rsync -av --progress $COOKBOOKDIR/demo/ $COOKBOOKDIR/workspace/demo --exclude .git
git status
git add .
git status
git commit -m "first upload with environments with nodes"
git status
# OK, needs some work on how we delivery review it... and bootstrap
delivery review
echo 'we did a delivery review above'
echo 'if workers are idle try this debug on the builder1 node'
echo 'login as roo, and "su - dbuild" user and try this'
echo 'knife job status'
echo 'knife job start chef-client builder1.myorg.chefdemo.net'
echo 'should kick off chef-client on builder1 and be successful'
echo 'knife node status, should return this....'
echo 'builder1.myorg.chefdemo.net	available'
echo 'if you are using 'srv-delivery' user must edit the following files on' 
echo 'the build nodes and change the username accordingly'
echo '/var/opt/delivery/workspace/.chef/knife.rb'
echo '/var/opt/delivery/workspace/etc/delivery.rb'
echo 'manual step 4, cannot boot strap till we add the acceptance env, so'
echo 'Press Review button in delivery gui, this will create the acceptance env'
echo 'at the Deploy step of the Acceptance Phase'
echo 'functional will fail...if so, press anykey as below to continue'
read -s -n 1 -p "4. Do, above steps, then Press any key to continue.."
echo 'we can add nodes and bootstrap the nodes, finally re-run Acceptance, Deliver once nodes bootstrapped...'
cd $COOKBOOKDIR/workspace/demo
# bootstrap the environment nodes
knife bootstrap acceptance01.myorg.chefdemo.net --sudo -x vagrant -P vagrant -N "acceptance01.myorg.chefdemo.net" -E "acceptance-myorg-myorg-demo-master" -r 'recipe[delivery_push_jobs::default],recipe[demo::default]'
# now re-run the acceptance phase and see if functional passes
# assuming acceptance passes, press the delivery button
# this should fail, but tt will create all the environments,
#  then we can Bootstrap the union node as union now exists
knife bootstrap union01.myorg.chefdemo.net --sudo -x vagrant -P vagrant -N "union01.myorg.chefdemo.net" -E "union" -r 'recipe[delivery_push_jobs::default],recipe[demo::default]'
# similarly for rehearsal01
knife bootstrap rehearsal01.myorg.chefdemo.net --sudo -x vagrant -P vagrant -N "rehearsal01.myorg.chefdemo.net" -E "rehearsal" -r 'recipe[delivery_push_jobs::default],recipe[demo::default]'
# similar for delivered
knife bootstrap delivered01.myorg.chefdemo.net --sudo -x vagrant -P vagrant -N "delivered01.myorg.chefdemo.net" -E "delivered" -r 'recipe[delivery_push_jobs::default],recipe[demo::default]'
echo 'knife node status command running, should return'
echo 'the builder1 node and the 4 application nodes, "AURD" '
echo 'if not debug as above on each node '
knife node status
echo 'nodes added and bootstraped, finally re-run Acceptance, Press Deliver button, in the delivery gui'

# add a run_list
#Create the org and the project in delivery server.
