sudo docker run -it -v $PWD/tomcat-users.xml:/usr/local/tomcat/conf/tomcat-users.xml -v $PWD/server.xml:/usr/local/tomcat/conf/server.xml -v $PWD/conjurize.sh:/conjurize.sh -v $PWD/ldap.conf:/etc/ldap/ldap.conf --rm -p 8080:8080 tomcatldap:1.0
