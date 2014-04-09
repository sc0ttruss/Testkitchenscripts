#/bin/bash
################################
#
#   Install Oracle using Testkitchen
#
################################
# setup the default locations for the install
# and the default OS
#
COOKBOOKDIR=~/Source/Testkitchen/Oracle
OS="centos-6.5"
OSnodots="centos-65"
COOKBOOK="oracle"
# this is the location of the Oracle binaries
# you will need an oracle account to obtain these
#
ORACLEBIN=/home/$USER/Source/Chef/Oraclebin
#  Location of the Oracle binaries inside the virtual machine
#
VMORACLEBIN=/opt/applications/chef/Oraclebin
# destroy old instances that were lying around
#
cd $COOKBOOKDIR
kitchen destroy $COOKBOOK-$OSnodots
cd -
rm -Rf $COOKBOOKDIR
mkdir -p $COOKBOOKDIR/cookbooks
cd $COOKBOOKDIR/cookbooks 
# download the oracle cookbook
#
#git clone https://github.com/edelight/chef-solo-search.git
git clone https://github.com/aririikonen/oracle
#git clone https://scottruss@bitbucket.org/dmoarir/echa-oracle-dev.git
cd ..
# create the config file for test kitchen
#
tee $COOKBOOKDIR/.kitchen.yml >/dev/null <<EOF
# setup of testkitchen to allow install of oracle via a chef script
# allow debug of kitchen scripts
# export KITCHEN_LOG='DEBUG'

driver:
  name: vagrant

# replace "$USER" with your own username/id 

driver_config:
  synced_folders: [  [ "$ORACLEBIN","$VMORACLEBIN", "create: false, disabled: false" ] ]
  customize:
    memory: 4048
    numvcpus: 2

provisioner:
  name: chef_solo

platforms:
  - name: $OS

suites:
  - name: $COOKBOOK
    data_bag_path: "$COOKBOOKDIR/data_bags"
    role_path: "$COOKBOOKDIR/roles"
    encrypted_data_bag_secret_key_path: "$COOKBOOKDIR/password.txt"
    run_list:
      - role[oracle_full_test]
      - role[oracle_createdb]
      - role[ora_cli_quickstart]      
    attributes:
EOF

# create the oracle role, for chef install of oracle
# the location of the oracle binaries below, is 
# inside the virtual machine, not on your local
# workstation.  Normally you should not change these 
# locations.  They are relative to the "synced_folders" above
mkdir -p $COOKBOOKDIR/roles
tee $COOKBOOKDIR/roles/oracle_full_test.rb >/dev/null <<EOF1
name "ora_quickstart"
  description "Role applied to Oracle quickstart test machines."
  run_list 'recipe[oracle]', 'recipe[oracle::logrotate_alert_log]', 'recipe[oracle::logrotate_listener]', 'recipe[oracle::createdb]'
  override_attributes :oracle => {:rdbms => {:latest_patch => {:url => 'file://$VMORACLEBIN/11.2/p16619892_112030_Linux-x86-64.zip'}, :opatch_update_url => 'file://$VMORACLEBIN/11.2/p6880880_112000_Linux-x86-64.zip', :install_files => ['file://$VMORACLEBIN/11.2/p10404530_112030_Linux-x86-64_1of7.zip', 'file://$VMORACLEBIN/11.2/p10404530_112030_Linux-x86-64_2of7.zip','file://$VMORACLEBIN/11.2/p10404530_112030_Linux-x86-64_4of7.zip']}}
EOF1

# this sets the oracle db password to "oraclesecret"
# the encrypted databag uses the shared secret in the
# file "password.txt" that follows
mkdir -p $COOKBOOKDIR/data_bags/oracle 
tee $COOKBOOKDIR/data_bags/oracle/foo.json >/dev/null <<EOF2
{
    "id":"foo",
    "pw":{
      "encrypted_data":"DBmrU40EVl9Z15rGIGwSnJ4IxCFieu+B0l7D3HAsdqU=\n",
      "iv":"o3ipr3zynuSunRNBdG8RDA==\n",
      "version":1,
      "cipher":"aes-256-cbc"
    }
}
EOF2

mkdir -p $COOKBOOKDIR/roles
tee $COOKBOOKDIR/roles/oracle_createdb.rb >/dev/null <<EOF3
name "ora_createdb"
  description "Role to create a db."
  run_list 'recipe[oracle::createdb]'
  override_attributes :oracle => {:rdbms => {:dbs => {:FOO => false}}}
EOF3


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
#
# Oracle client components
#
mkdir -p $COOKBOOKDIR/roles
tee $COOKBOOKDIR/roles/ora_cli_quickstart.rb >/dev/null <<EOF5
    name "ora_cli_quickstart"
    description "Role applied to Oracle Client quickstart test machines."
    run_list 'recipe[oracle::oracli]'
    override_attributes :oracle => {:client => {:latest_patch => {:url => 'file://$VMORACLEBIN/11.2/p16619892_112030_Linux-x86-64.zip'}, :opatch_update_url => 'file://$VMORACLEBIN/11.2/p6880880_112000_Linux-x86-64.zip', :install_files => ['file://$VMORACLEBIN/11.2/p10404530_112030_Linux-x86-64_4of7.zip']}}
EOF5

# this is just a copy of the database databag.
# with the same password, "oraclesecret"
mkdir -p $COOKBOOKDIR/data_bags/oracli
tee $COOKBOOKDIR/data_bags/oracli/foo.json >/dev/null <<EOF6
{
    "id":"foo",
    "pw":{
      "encrypted_data":"DBmrU40EVl9Z15rGIGwSnJ4IxCFieu+B0l7D3HAsdqU=\n",
      "iv":"o3ipr3zynuSunRNBdG8RDA==\n",
      "version":1,
      "cipher":"aes-256-cbc"
    }
}
EOF6


kitchen list
kitchen create $COOKBOOK-$OSnodots
kitchen converge $COOKBOOK-$OSnodots



#License and Authors
#===================
#
#Email:: <copyright@inetmedia.co.uk>
#Author:: Scott Russell
#
#Copyright:: 2013, Scott Russell
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
