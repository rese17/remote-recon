#!/bin/bash

REMOTE_HOST=$2

# set the count and run N pararell clients 
if [ $REMOTE_HOST == local ]
then
		export ROOT_DIR="/home/rese/programming-projects/bash/remote-node"
else
		export ROOT_DIR="~/remote-recon"
fi 

atexit() {
		echo "exiting..."
		kill -KILL -$$
		# echo "" > .client_pids
}


cleanup (){
		echo "exiting..."
		cat .client_pids
}

trap "atexit" INT 
trap "cleanup" EXIT

COUNT=$1
echo $COUNT
for i in $(seq $COUNT); do
		$ROOT_DIR/client.sh $REMOTE_HOST $i  &
		kill -CONT $pid
done 

while [ ! -z "a" ]; do sleep 1 ; done  

