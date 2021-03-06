#!/usr/bin/env bash

CARBON_HOME_PATH=/home/wso2user/wso2esb-5.0.0
#remove default java opts
sed -i '/-Xms256m/d' $CARBON_HOME_PATH/bin/wso2server.sh

sed -i "/port=\"9763\"/a    proxyPort=\"80\"" $CARBON_HOME_PATH/repository/conf/tomcat/catalina-server.xml
sed -i "/port=\"9443\"/a    proxyPort=\"443\"" $CARBON_HOME_PATH/repository/conf/tomcat/catalina-server.xml
#sed -i '/<WebContextRoot>/c\\t<WebContextRoot>/dss</WebContextRoot>' $CARBON_HOME_PATH/repository/conf/carbon.xml

#Change file properties
cd $CARBON_HOME_PATH/repository/conf/ && bash config_modifier.sh;

#Changing tenant admin password
if [ -z ${TENANT_PASSWORD+x} ]; then
    echo "TENANT_PASSWORD is not set.";
    echo "Generating tenant admin password.";
    TENANT_PASSWORD=${TENANT_PASS:-$(pwgen -s 12 1)}
    echo "========================================================================="
    echo "Credentials for the instance:"
    echo
    echo "    user name: admin@$TENANT_DOMAIN"
    echo "    password : $TENANT_PASSWORD"
    echo "========================================================================="
else
    echo "TENANT_PASSWORD set by user.";
fi

export TENANT_PASSWORD=$TENANT_PASSWORD;

#Changing admin password
if [ -z ${ADMIN_PASSWORD+x} ]; then
    echo "ADMIN_PASSWORD is not set.";
    echo "Generating admin password.";
    ADMIN_PASSWORD=${ADMIN_PASS:-$(pwgen -s 12 1)}
    #echo "========================================================================="
    #echo "Credentials for the instance:"
    #echo
    #echo "    user name: admin"
    #echo "    password : $ADMIN_PASSWORD"
    #echo "========================================================================="
    sed -i "s/.*<Password>admin<\/Password>.*/<Password>$ADMIN_PASSWORD<\/Password>/" $CARBON_HOME_PATH/repository/conf/user-mgt.xml
else
    echo "ADMIN_PASSWORD set by user.";
fi

#Remove bundles from plugins dir and the bundles.info to minimize jaggery runtime
#PLUGINS_DIR_PATH="$CARBON_HOME_PATH/repository/components/plugins/"
#DEFAULT_PROFILE_BUNDLES_INFO_FILE="$CARBON_HOME_PATH/repository/components/default/configuration/org.eclipse.equinox.simpleconfigurator/bundles.info"
#LIST_OF_BUNDLES_FILE="removed-bundles.txt"

#while read in; do rm -rf "$PLUGINS_DIR_PATH""$in" && sed -i "/$in/d" "$DEFAULT_PROFILE_BUNDLES_INFO_FILE"; done < $LIST_OF_BUNDLES_FILE

#Remove sample
rm -rf $CARBON_HOME_PATH/repository/deployment/server/axis2services/*
rm -rf $CARBON_HOME_PATH/repository/deployment/server/webapps/*

#set user defined TIMEZONE
if [ -n "$TIMEZONE" ]; then
        cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime
        echo $TIMEZONE >  /etc/timezone
fi

#Enabling log enabled log4j properties
echo $LOG4J_PROPERTIES | tr "," "\n" >>  $CARBON_HOME_PATH/repository/conf/log4j.properties

#Set userdefined SO_TIMEOUT value in axis2 config
if [ -n "$SO_TIMEOUT" ]; then
	sed -i '/<transportSender name="http" class="org.apache.axis2.transport.http.CommonsHTTPTransportSender">/a <parameter name="SO_TIMEOUT">'$SO_TIMEOUT'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2_blocking_client.xml
	sed -i '/<transportSender name="https" class="org.apache.axis2.transport.http.CommonsHTTPTransportSender">/a <parameter name="SO_TIMEOUT">'$SO_TIMEOUT'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2_blocking_client.xml
fi

#Set userdefined SO_TIMEOUT value in axis2_blocking_client config
if [ -n "$SO_TIMEOUT" ]; then
        sed -i '/<transportSender name="http" class="org.apache.axis2.transport.http.CommonsHTTPTransportSender">/a <parameter name="SO_TIMEOUT">'$SO_TIMEOUT'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2_blocking_client.xml
        sed -i '/<transportSender name="https" class="org.apache.axis2.transport.http.CommonsHTTPTransportSender">/a <parameter name="SO_TIMEOUT">'$SO_TIMEOUT'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2_blocking_client.xml
fi

#set SMTP server information, check com.sun.mail.smtp package documentation for descriptions of properties
if [ -n "$MAIL_SMTP_HOST" ]; then
        sed -i '/<parameter name="mail.smtp.host">smtp.gmail.com/c <parameter name="mail.smtp.host">'$MAIL_SMTP_HOST'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2.xml
fi

if [ -n "$MAIL_SMTP_PORT" ]; then
        sed -i '/<parameter name="mail.smtp.port">587/c <parameter name="mail.smtp.port">'$MAIL_SMTP_PORT'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2.xml
fi

if [ -n "$MAIL_STARTTLS_ENABLE" ]; then
        sed -i '/<parameter name="mail.smtp.starttls.enable">true/c <parameter name="mail.smtp.starttls.enable">'$MAIL_STARTTLS_ENABLE'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2.xml
fi

if [ -n "$MAIL_SMTP_AUTH" ]; then
        sed -i '/<parameter name="mail.smtp.auth">true/c <parameter name="mail.smtp.auth">'$MAIL_SMTP_AUTH'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2.xml
fi

if [ -n "$MAIL_SMTP_USER" ]; then
        sed -i '/<parameter name="mail.smtp.user">synapse.demo.0/c <parameter name="mail.smtp.user">'$MAIL_SMTP_USER'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2.xml
fi

if [ -n "$MAIL_SMTP_PASSWORD" ]; then
        sed -i '/<parameter name="mail.smtp.password">mailpassword/c <parameter name="mail.smtp.password">'$MAIL_SMTP_PASSWORD'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2.xml
fi

if [ -n "$MAIL_SMTP_FROM" ]; then
        sed -i '/<parameter name="mail.smtp.from">synapse.demo.0@gmail.com/c <parameter name="mail.smtp.from">'$MAIL_SMTP_FROM'</parameter>' $CARBON_HOME_PATH/repository/conf/axis2/axis2.xml
fi

#Check whether JAVA_OPTS env variable is defined and is not empty
if [[ $JAVA_OPTS && ${JAVA_OPTS-_} ]]; then
	export JAVA_OPTS=$JAVA_OPTS
else
    #Calculate max heap size and the perm size for Java Opts
    #Check whether TOTAL_MEMORY env variable defined or and not empty
	if [[ $TOTAL_MEMORY && ${TOTAL_MEMORY-_} ]]; then
	    let MAX_HEAP_SIZE=$TOTAL_MEMORY/256*128
	    let MAX_META_SPACE_SIZE=$TOTAL_MEMORY/256*128
	    JAVA_OPTS="-Xms128m -Xmx"$MAX_HEAP_SIZE"m -XX:MaxMetaspaceSize="$MAX_META_SPACE_SIZE"m"
	    export JAVA_OPTS=$JAVA_OPTS
	fi
fi

$CARBON_HOME_PATH/bin/wso2server.sh
