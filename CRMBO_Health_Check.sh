#!/bin/bash

# Crmbo health checker
# Version 0.2
# Feb, 16 2016

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
     source $CONFIG_FILE

     if [ $? -ne 0 ] ; then
#         echo "Error occurred getting URL $1"
          echo "crm_status=${CRM_DOWN}" > $CONFIG_FILE
          curl -X POST --data-urlencode 'payload={"channel":"'"${SLACK_CHANNEL}"'", "username": "'"${SLACK_BOTNAME}"'", "text": "'"CRMBO $1 is down. Error occurred getting URL"'", "icon_emoji": ":ghost:"}' ${SLACK_HOSTNAME}
         if [ $? -eq 6 ]; then
#             echo "Unable to resolve host"
              echo "crm_status=${CRM_DOWN}" > $CONFIG_FILE
              curl -X POST --data-urlencode 'payload={"channel":"'"${SLACK_CHANNEL}"'", "username": "'"${SLACK_BOTNAME}"'", "text": "'"CRMBO $1 is down. Unable to resolve host"'", "icon_emoji": ":ghost:"}' ${SLACK_HOSTNAME}
         fi
         if [ $? -eq 7 ]; then
#             echo "Unable to connect to host"
              echo "crm_status=${CRM_DOWN}" > $CONFIG_FILE
              curl -X POST --data-urlencode 'payload={"channel":"'"${SLACK_CHANNEL}"'", "username": "'"${SLACK_BOTNAME}"'", "text": "'"CRMBO $1 is down. Unable to connect to host"'", "icon_emoji": ":ghost:"}' ${SLACK_HOSTNAME}
         fi
#         exit 1
     else
         if [ $crm_status = $CRM_DOWN ]; then
              echo "crm_status=${CRM_UP}" > $CONFIG_FILE
              curl -X POST --data-urlencode 'payload={"channel":"'"${SLACK_CHANNEL}"'", "username": "'"${SLACK_BOTNAME}"'", "text": "'"CRMBO $1 is UP."'", "icon_emoji": ":ghost:"}' ${SLACK_HOSTNAME}
         fi
     fi
}

crm_check() {
    curl -s -o "/dev/null" $1
    check $1;
}

crm_check $CRMBO_SERVER_QA;
#crm_check $CRMBO_SERVER_CFD;