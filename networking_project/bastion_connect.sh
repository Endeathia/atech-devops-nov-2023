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

NEW=$(ssh -q -o StrictHostKeyChecking=no -i $KEY_PATH ubuntu@$1  'ls new_key > /dev/null; echo $?')

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

        if [[ $NEW -eq 0 ]];

        then

                scp -q -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$1:new_key new_key

                ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$1 -t "ssh -o StrictHostKeyChecking=no ubuntu@$2 -i new_key"

        else

                ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$1 -t "ssh -o StrictHostKeyChecking=no ubuntu@$2 -i $KEY_PATH"

        fi



fi

## Add an optional command

if [[ $# == 3 ]]

then

        if [[ $NEW -eq 0 ]];

        then

                scp -q -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$1:new_key new_key

                ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$1 -t "ssh -o StrictHostKeyChecking=no ubuntu@$2 -i new_key -t $3"

        else

                ssh -q -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@$1 -t "ssh -o StrictHostKeyChecking=no ubuntu@$2 -i $KEY_PATH -t $3"
                fi
        fi
