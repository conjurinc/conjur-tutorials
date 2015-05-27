. ./my_keys.sh
. ./my_conjur_env.sh

env | grep CONJUR

if [ -z "$TOMCAT_PORT" ]; then
    export TOMCAT_PORT=8080
fi

sudo docker run -it \
    -v $PWD/tomcat-users.xml:/usr/local/tomcat/conf/tomcat-users.xml \
    -v $PWD/server.xml:/usr/local/tomcat/conf/server.xml \
    -v $PWD/conjurize.sh:/conjurize.sh \
    -v $PWD/my_ldap.conf:/etc/ldap/ldap.conf \
    -e CONJUR_HOST=$CONJUR_HOST \
    -e TOMCAT_HOST=$TOMCAT_HOST \
    -e CONJUR_ACCOUNT=$CONJUR_ACCOUNT \
    -p $TOMCAT_PORT:8080 tomcatldap:1.0
