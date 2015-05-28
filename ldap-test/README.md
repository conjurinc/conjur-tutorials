#ldap-test

## Set-up the Environment

create a file called policy.json:
```
{
     "collection":"development",
     "version":"1.0"
}
```
run the script to set-up the environment
```
set_conjur_env.sh
```


## Set up secondary groups


```
# group expected by Tomcat
conjur group create --as-group=security_admin manager-gui
# it will only be visible in LDAP searches if it has an UID
conjur group update --gidnumber=1999
# it will only be visible in LDAP searches if host is member of this group 
conjur group members add layer:development/ldap-1.12/tomcats
# it will only be visible in LDAP if user is a direct member of the group
conjur group members add manager-gui user:kgilpin@development-ldap-1-12
```

## test the LDAP connection
This will run the samples described at https://developer.conjur.net/reference/services/ldap

```./ldap-test.sh```

NOTE: BEFORE you run this make sure you've added the information in my_ldap.conf to you openldap client configuration, otherwise the LDAPS connection to the conjur server will FAIL

## build the docker file

sudo docker build -t tomcatldap:1.0 .

## start the docker container

./run.sh

