#!/bin/bash







if [[  -z ${KEY_PATH} ]]



then



        echo "KEY_PATH env var is expected"



        exit 5



fi



####



USER="ubuntu"







if [[ $# != 1 ]]



then



        echo "Please provide IP address"



        exit 5



fi



#Generate a ssh Key-Pair



ssh-keygen -t rsa -N "" -f new_key

# Copy the public Key to the private instance

scp -i $KEY_PATH ~/new_key.pub ubuntu@$1:~/

## Copy the contents of the public key to Authorized Files and remove the key from the private instance

ssh -i $KEY_PATH ubuntu@$1 "cat ~/new_key.pub >> ~/.ssh/authorized_keys && rm new_key.pub"



#remove the key from Public Instance

rm new_key new_key.pub



echo "Key rotation successful."

