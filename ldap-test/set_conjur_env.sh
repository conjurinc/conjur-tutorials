#!/bin/bash

set -o xtrace

if [ -z "$CONJURRC" ]; then
    echo "Using CONJURRC from ~/.conjurrc" >&2
    CONJURRC=~/.conjurrc
fi

echo 'export CONJUR_HOST=\' >> my_conjur_env.sh
cat $CONJURRC | grep appliance | cut -d/ -f3 >> my_conjur_env.sh
echo 'export CONJUR_ACCOUNT=\' >> my_conjur_env.sh
conjur authn whoami | jsonfield account >> my_conjur_env.sh
echo 'export CONJUR_POLICY_VERSION=\' >> my_conjur_env.sh
cat policy.json | jsonfield version >> my_conjur_env.sh
echo 'export CONJUR_POLICY_VERSION_DASHED=\' >> my_conjur_env.sh
cat policy.json | jsonfield version | tr '.' '-' >> my_conjur_env.sh
echo 'export CONJUR_COLLECTION=\' >> my_conjur_env.sh
cat policy.json | jsonfield collection >> my_conjur_env.sh



chmod a+x my_conjur_env.sh

#now add the information from the environment
. ./my_conjur_env.sh

export CONJUR_LDAP_POLICY=$CONJUR_COLLECTION/ldap-$CONJUR_POLICY_VERSION
export TOMCAT_HOST=tomcat.$CONJUR_COLLECTION-$CONJUR_POLICY_VERSION.example.com

#update the file with the tomcat host

echo 'export TOMCAT_HOST=\' >> my_conjur_env.sh
echo $TOMCAT_HOST >> my_conjur_env.sh

echo "Creating the host..."
# Why do this?, it will be done by policy
conjur host create $TOMCAT_HOST | tee tomcat.json

echo "Creating objects...."
conjur policy load --as-group security_admin --collection $CONJUR_COLLECTION --context ldap.json ldap.rb 

echo "Adding host to layer..."
conjur layer hosts add $CONJUR_LDAP_POLICY/tomcats $TOMCAT_HOST

echo Dashed Version=$CONJUR_POLICY_VERSION_DASHED

echo 'export HOST_API_KEY=\' >> my_keys.sh
cat tomcat.json | jsonfield api_key >> my_keys.sh
echo 'export KEVIN_API_KEY=\' >> my_keys.sh
cat ldap.json | jsonfield api_keys.$CONJUR_ACCOUNT:user:kevin@$CONJUR_COLLECTION-ldap-$CONJUR_POLICY_VERSION_DASHED >> my_keys.sh
echo 'export KEVIN_USERNAME=\' >> my_keys.sh
echo kevin@$CONJUR_COLLECTION-ldap-$CONJUR_POLICY_VERSION_DASHED >> my_keys.sh

chmod a+x my_keys.sh

. ./my_keys.sh

echo "Creating LDAP Configuration"

echo URI ldaps://$CONJUR_HOST >> my_ldap.conf
echo TLS_CERT /etc/conjur-$(echo $CONJUR_ACCOUNT).pem >> my_ldap.conf
echo TLS_REQCERT demand >> my_ldap.conf



echo "Conjurizing host...."

cat tomcat.json | conjurize > conjurize.sh


