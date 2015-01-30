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
git clone https://github.com/opscode-cookbooks/nginx.git
#git clone https://github.com/opscode-cookbooks/artifact.git
#git clone https://github.com/opscode-cookbooks/nexus.git
git clone https://github.com/opscode-cookbooks/maven.git
git clone https://github.com/opscode-cookbooks/windows.git
git clone https://github.com/opscode-cookbooks/chef_handler.git
git clone https://github.com/opscode-cookbooks/bluepill.git
git clone https://github.com/opscode-cookbooks/rsyslog.git
git clone https://github.com/opscode-cookbooks/ohai.git
git clone https://github.com/opscode-cookbooks/ark.git
knife cookbook site download nexus
tar -xvzf nexus*.gz
knife cookbook site download artifact
tar -xvzf artifact*.gz
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
  require_chef_omnibus: 11.16.0
  name: vagrant

driver_config:
  customize:
    memory: 4048
    $CPUVAR: 2

provisioner:
  name: chef_solo

platforms:
  - name: $OS
    driver:
      network:
      #- ["forwarded_port", {host: 8800, guest: 80}]
        - ["private_network", {ip: "192.168.56.42"}]

suites:
  - name: $COOKBOOK
    run_list:
      - recipe[java::oracle]
      - recipe[jenkins::master]
      - recipe[nexus]
      - recipe[maven]
    attributes:
      java:
        oracle:
          accept_oracle_download_terms: true
        install_flavor: oracle
      nexus:
        app_server_proxy:
          use_self_signed: true
        version: '2.11.1-01'
        external_version: '2.11.1'
        checksum: 'f3c2aee1aa4bf6232b22393c1c9c1da3dfacb9ccca7ee58c85507c85748b1e67'
        cli:
          ssl:
            verify: false
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

tee $COOKBOOKDIR/make_encrypted_nexus_data_bag.rb >/dev/null <<EOF5
require 'rubygems'
require 'chef/encrypted_data_bag_item'
 
secret = Chef::EncryptedDataBagItem.load_secret('./password.txt')
#data = {"id" => "_wildcard", "credentials" => {:default_admin=>{:username=>"admin", :password=>"admin123"} , {:updated_admin=>{:username=>"admin", :password=>"new_password"}  }  }, "license" =>{:file => "base64d license file" } } 
data = {
  "id"=> "_wildcard",
  "credentials"=> {
    "default_admin"=> {
      "username"=> "admin",
      "password"=> "admin123"
    },
    "updated_admin"=> {
      "username"=> "admin",
      "password"=> "new_password"
    },
  },
  "license"=> {
    "file"=> "base64d license file"
  }
}

encrypted_data = Chef::EncryptedDataBagItem.encrypt_data_bag_item(data, secret)
 
FileUtils.mkpath('./data_bags/nexus')
File.open('./data_bags/nexus/_wildcard.json', 'w') do |f|
  f.print encrypted_data.to_json
end
EOF5

tee $COOKBOOKDIR/make_encrypted_nexus_ssl_files_data_bag.rb >/dev/null <<EOF6
require 'rubygems'
require 'chef/encrypted_data_bag_item'
 
secret = Chef::EncryptedDataBagItem.load_secret('./password.txt')
#data = {"id" => "_wildcard", "credentials" => {:default_admin=>{:username=>"admin", :password=>"admin123"} , {:updated_admin=>{:username=>"admin", :password=>"new_password"}  }  }, "license" =>{:file => "base64d license file" } } 
data = {
  "id"=> "_wildcard",
  "fully-qualified-domain-name"=> {
    "crt"=> "base64-encoded-ssl-certificate",
    "key"=> "base64-encoded-private-key"
  }
}

encrypted_data = Chef::EncryptedDataBagItem.encrypt_data_bag_item(data, secret)
 
FileUtils.mkpath('./data_bags/nexus_ssl_files')
File.open('./data_bags/nexus_ssl_files/_wildcard.json', 'w') do |f|
  f.print encrypted_data.to_json
end
EOF6

cd $COOKBOOKDIR

# make the two encrypted databags that will be needed
ruby make_encrypted_nexus_data_bag.rb
ruby make_encrypted_nexus_ssl_files_data_bag.rb

kitchen list
kitchen create $COOKBOOK-$OSNODOTS
kitchen converge $COOKBOOK-$OSNODOTS

