#!/bin/bash

########################################################

if [[  -z ${KEY_PATH} ]]

then

        echo "KEY_PATH env var is expected"

        exit 5

fi





if [ "$#" -lt 1 ]; then

    echo "Please provide bastion IP address"

    exit 5

fi





USER="ubuntu"



# Connect to Public Instance

if [[ $# == 1 ]]

then

        ssh -i $KEY_PATH "$USER@$1"

fi

#####

##Start the Agent and add the Key

#eval $(ssh-agent -s)

#ssh-add $KEY_PATH



# Conenct to Private using Public: ( must have two argument when:)

if [[ $# == 2 ]]

then

        ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$1 -t "ssh -o StrictHostKeyChecking=no ubuntu@$2 -i \$(echo \$KEY_PATH)"

         #ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" -J "$USER@$1" "$USER@$2"



fi

## Add an optional command

if [[ $# == 3 ]]

then

        ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$1 -t "ssh -o StrictHostKeyChecking=no ubuntu@$2 -i \$(echo \$KEY_PATH)" $3

        #ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" -J "$USER@$1" "$USER@$2"

fi



###########################################################################################

