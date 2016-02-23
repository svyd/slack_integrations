#!/bin/bash

# Crmbo health checker
# Version 0.4
# Feb, 23 2016

#Modify these variables for your environment
CRMBO_SERVER_QA="IP_CRM_QA"
CRMBO_SERVER_CFD="IP_CRM_CFD"
SLACK_HOSTNAME="SLACK_HOSTNAME"
SLACK_CHANNEL="#alerts"
SLACK_BOTNAME="crmbo"

CONFIG_FILE="CONFIG_FILE_PATH"
CRM_UP="UP"
CRM_DOWN="DOWN"

check() {
     if [ $? -ne 0 ] ; then
          #echo "Error occurred getting URL $1"
          sed -i "s,^\($1=\).*,\1"${CRM_DOWN}","  $CONFIG_FILE
          curl -X POST --data-urlencode 'payload={"channel":"'"${SLACK_CHANNEL}"'", "username": "'"${SLACK_BOTNAME}"'", "text": "'"CRMBO $3 is down. Error occurred getting URL"'", "icon_emoji": ":ghost:"}' ${SLACK_HOSTNAME}
         if [ $? -eq 6 ]; then
              #echo "Unable to resolve host"
	      sed -i "s,^\($1=\).*,\1"${CRM_DOWN}","  $CONFIG_FILE
              curl -X POST --data-urlencode 'payload={"channel":"'"${SLACK_CHANNEL}"'", "username": "'"${SLACK_BOTNAME}"'", "text": "'"CRMBO $3 is down. Unable to resolve host"'", "icon_emoji": ":ghost:"}' ${SLACK_HOSTNAME}
         fi
         if [ $? -eq 7 ]; then
              #echo "Unable to connect to host"
	      sed -i "s,^\($1=\).*,\1"${CRM_DOWN}","  $CONFIG_FILE
              curl -X POST --data-urlencode 'payload={"channel":"'"${SLACK_CHANNEL}"'", "username": "'"${SLACK_BOTNAME}"'", "text": "'"CRMBO $3 is down. Unable to connect to host"'", "icon_emoji": ":ghost:"}' ${SLACK_HOSTNAME}
         fi
#         exit 1
     else
         if [ $2 = $CRM_DOWN ]; then
              sed -i "s,^\($1=\).*,\1"${CRM_UP}","  $CONFIG_FILE
              curl -X POST --data-urlencode 'payload={"channel":"'"${SLACK_CHANNEL}"'", "username": "'"${SLACK_BOTNAME}"'", "text": "'"CRMBO $3 is UP."'", "icon_emoji": ":ghost:"}' ${SLACK_HOSTNAME}
         fi
     fi
}

config_read() {
    source $CONFIG_FILE
}

crm_check() {
    curl -s -o "/dev/null" $3
    check $1 $2 $3;
}

config_read;
crm_check crm_status_qa $crm_status_qa $CRMBO_SERVER_QA;
crm_check crm_status_cfd $crm_status_cfd $CRMBO_SERVER_CFD;
