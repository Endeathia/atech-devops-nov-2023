#!/bin/bash

public_ip=$1
if [[ $# -ne 1 ]]

then
        echo "Please provide an IP address"

        exit 5

fi



#Use curl to send the following Client Hello HTTP request to the server:

HELLO=$(curl -X POST -H 'Content-Type: application/json' -d '{

   "version": "1.3",

   "ciphersSuites": [

      "TLS_AES_128_GCM_SHA256",

      "TLS_CHACHA20_POLY1305_SHA256"

    ], 

   "message": "Client Hello"



}' $1:8080/clienthello)



#######

## Save to Variable

SESSION_ID=$(echo $HELLO | jq -r ".sessionID")

echo $HELLO | jq -r ".serverCert" > cert.pem
## CA validation:

# Downlaod the Amazon Cert

wget https://raw.githubusercontent.com/AlexeyMihaylovDev/atech-devops-nov-2023/main/networking_project/tls_webserver/cert-ca-aws.pem

openssl verify -CAfile cert-ca-aws.pem cert.pem



if [[ $? != 0 ]]

then

        echo "Server Certificate is invalid."

        exit 5

fi

##############################################################################################################################################################

#### Generate a master key and encrypt it

openssl rand 32 | base64  > MASTER_KEY

openssl smime -encrypt -aes-256-cbc -in MASTER_KEY -outform DER cert.pem | base64 -w 0 > ENCRYPTED_MASTER

export ENCRYPTED_MASTER=$(cat ENCRYPTED_MASTER)



EXCHANGE=$(curl -X POST -H 'Content-Type: application/json' -d '{

   "sessionID": "'$SESSION_ID'",

   "masterKey": "'$ENCRYPTED_MASTER'",

   "sampleMessage": "Hi server, please encrypt me and send to client!"

}' $1:8080/keyexchange)



ENCRYPT=$(echo $EXCHANGE | jq -r ".encryptedSampleMessage")

echo $ENCRYPT | base64 -d > encSampleMsgReady.txt

#file encSampleMsgReady.txt is ready now to be used in "openssl enc...." command

openssl enc -d -aes-256-cbc -pbkdf2 -in encSampleMsgReady.txt -out original_message.txt -pass file:MASTER_KEY



if [[ $(cat original_message.txt) == "Hi server, please encrypt me and send to client!" ]];

then

        cat original_message.txt

        echo "Client-Server TLS handshake has been completed successfully"

else

        echo "Server symmetric encryption using the exchanged master-key has failed."

        exit 6

fi


# TODO Your solution here