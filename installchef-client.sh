#!/bin/bash
################################
#
#   Install chef-client using Testkitchen
#
################################
# setup the default locations for the install
# and the default OS
#
COOKBOOKDIR=$HOME/Source/Testkitchen/Chef-client
OS="centos-6.5"
OSNODOTS=${OS//\./} # replace the "dot" in the "OS" variable
COOKBOOK="chef-client"
# destroy old instances that were lying around
cd $COOKBOOKDIR
kitchen destroy $COOKBOOK-$OSNODOTS
cd -
rm -Rf $COOKBOOKDIR
mkdir -p $COOKBOOKDIR/cookbooks
cd $COOKBOOKDIR/cookbooks
git clone https://github.com/opscode-cookbooks/chef-client.git
git clone https://github.com/opscode-cookbooks/cron.git
git clone https://github.com/stevendanna/logrotate.git
git clone https://github.com/opscode-cookbooks/windows.git
git clone https://github.com/opscode-cookbooks/chef_handler.git
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
echo `pwd`
tee $COOKBOOKDIR/.kitchen.yml >/dev/null <<EOF
# setup of testkitchen to allow install of jenkins via a chef script
# allow debug of kitchen scripts
# export KITCHEN_LOG='DEBUG'

driver:
  # Getting error "NoMethodError: undefined method 'new' for Ark:Module" with Chef 12 #92   
  # require_chef_omnibus: 11.16.0


  name: vagrant

driver_config:
  customize:
    memory: 4048
    $CPUVAR: 2

provisioner:
  name: chef_solo
  # Use the local chef-client rpm specified in install_chef_rpm.sh:
  chef_omnibus_url: file:///mnt/share/install_chef_rpm.sh

  # install_chef_rpm has the following contents
  # and needs a chown 755 after creation.
  # of course you put it in this directory
  # /Users/srussell/Source/Chef/Client
  # content below
  # rpm -Uvh /mnt/share/chef*


platforms:
  - name: $OS
    driver:
      network:
      #- ["forwarded_port", {host: 8800, guest: 80}]
        - ["private_network", {ip: "192.168.56.43"}]
      synced_folders:
      - ["/Users/srussell/Source/Chef/Client", "/mnt/share", "disabled: false"]
suites:
  - name: $COOKBOOK
    run_list:
      - recipe[chef-client::config]
      - recipe[chef-client::default]
EOF


# encrypted data bag secret file, that was used
# to generate the encrypted "foo.json" file above
mkdir -p $COOKBOOKDIR
tee $COOKBOOKDIR/password.txt >/dev/null <<EOF4
ZHymME3g7lAyDZ17Q+k1RAURAcP2mdUEvVicZhA4aPNbAlH+mcXPs5GvE4bYn6zu
Ko/XE1fDLv5lV7eJhouZ2Z1u50KR82OWKZwfjAznat+6mK8mchBNYr0PQwUIe4pG
Em1Ufq3JLk1vBUO39wsGSKE1n1GX6IQ5DhGTR5jpe7Hj+qiOQTgkGZBxtL5Xk+Wu
I/9HyU9L4wj+GPF+VvybF0Zi4jU8zRIcaliwWHnUyQho/jJD7WF47VHMYSZnvSRV
h6AG97GMlnXz1TLTJc/svBMhfTgYhaxb0XZckvUuunnXbamKx40Yypu+4xgk/ksE
OMSlulOr+c5bjj1aoK5Jms4L0ckv3+ojQh2fBLs0Mj1F0zX5RtY0E3Oy0BgHApxG
rT1mqXzxhXYmLNl66x0dpMZHRnPmaNOhxLfZmgADBTVrq+UQAx+1CzjwUXcXhtAA
k775Wz4VP1+ARFOeAZBz/JymWAZ2pHy5M4INWV+elakzf8yYWmIb6tkDijKii6jB
yaI5cndwAGvlqDEyrswU3WErekNA7aakWE0d4JjWns8aW05S4AckLXNa1VYgDDWD
9OO7O6GpcPEVPPJDDKkFjKnbLFeblO9akn/ppY4EpoL5/Fhv9hjDlVIzcF744v2v
t+sYV5CnsbwcpOcrFiGDjvDfHty8Zu+eoNZQlXKIYaQ=
EOF4

cd $COOKBOOKDIR

kitchen list
kitchen create $COOKBOOK-$OSNODOTS
kitchen converge $COOKBOOK-$OSNODOTS

