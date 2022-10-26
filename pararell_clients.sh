#!/bin/bash

REMOTE_HOST=$2

# set the count and run N pararell clients 
if [ $REMOTE_HOST == local ];
then
		export ROOT_DIR=/home/rese/programming-projects/bash/remote-node;
else
		export ROOT_DIR=~/remote-recon
fi 

get_ngrok_url (){
		# how the freaking fuck should i dget that freaking url 
		# curl "localhost"
		url=$`curl -s --location --request POST "https://data.mongodb-api.com/app/data-qwghm/endpoint/data/v1/action/findOne"  \
							 --header "Content-Type: application/json" \
							 --header "Access-Control-Request-Headers: \*" \
							 --header "api-key: llHw9CnMFOKEBLS4r5oJxrp41bexNZrpKmHD0prMZshCGykhgMyDdzDjK3MrjJ0p" \
							 --data-raw \
							 "{\"collection\":\"config\", \"database\":\"recon-config\", \"dataSource\":\"recon-config\", \"filter\":{\"key\":\"1\"}}"`
		echo ${url:1} | jq -r '.document.url'
}

if [ $REMOTE_HOST == "local" ]
then 
		export NGROK_URL="http://localhost:8020"
else
		export NGROK_URL="$(get_ngrok_url)"
fi


gen_random_id(){
# generate 32 alphanumeric id using python random and string packages
		python3 -c 'from string import ascii_letters, digits; from random import choice;print("".join(choice (ascii_letters + digits) for i in range(32)))'
}

atexit() {
		echo "exiting..."
		kill -KILL -$$
		# echo "" > .client_pids
}

trap "atexit" INT EXIT

COUNT=$1
echo $COUNT
ENV_ID="$(gen_random_id)"
for i in $(seq $COUNT); do
		$(echo $ROOT_DIR)/client.sh $REMOTE_HOST $i $ENV_ID &
		pid=$!
		kill -CONT $pid 2> /dev/null
done 

while [ ! -z "a" ]; do sleep 1 ; done  

