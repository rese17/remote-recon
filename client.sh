#!/bin/bash

# the programs to run are all stored in here
# TEST:
# save the current dir and go back again
REMOTE_HOST=$1
status_file=.status_map_$2
script_file=.cmd_script_$2
HOST_ID=$3
CLIENT_PID=$$

trap cleanup EXIT
trap cleanup INT
trap atexit INT

atexit() {
		echo "exiting..."
		kill -KILL -$$
		# echo "" > .client_pids
}

# check if the remote host is local or not

echo "setting th root dir to $ROOT_DIR"
source $ROOT_DIR/scripts/tools.sh

# use the content/bin in the path 
PATH="~/content/bin/:$PATH"

map_get_field(){
		# DEBUG:
		case $1 in
				"id") cat $status_file | sed -n '1p';;
				"chunk") cat $status_file | sed -n '2p';;
				"status") cat $status_file | sed -n '3p';;
				"pid" ) cat $status_file | sed -n '4p';; 
				"debug" ) cat $status_file | sed -n '5p';; 
		esac 
		
}

map_set_field (){
		if [ ! -f $status_file ]
		then
				# TODO: should check if debug is enabled
				echo "creating $status_file file "
				
				touch $status_file
				echo "testid" > $status_file
				echo "testchunk" >> $status_file
				echo "idle" >> $status_file
				echo "testpid" >> $status_file
				echo "debug" >> $status_file
		fi
		
		case $1 in
				"id") sed -i "1 s/.*/$2/" $(echo $status_file);;
				"chunk") sed -i "2 s/.*/$2/" $(echo $status_file);;
				"status") sed -i "3 s/.*/$2/" $(echo $status_file);;
				"pid") sed -i "4 s/.*/$2/" $(echo $status_file);;
				"debug") sed -i "5 s/.*/$2/" $(echo $status_file);;
						
				# TODO: add more pairs
		esac 
		
}


gen_random_id(){
# generate 32 alphanumeric id using python random and string packages
		python3 -c 'from string import ascii_letters, digits; from random import choice;print("".join(choice (ascii_letters + digits) for i in range(32)))'
}

get_status(){
		# returns the status from the 
		# TODO: use the file map to store those things
		echo $(map_get_field "status")
		# if [ ! -f .client_status ]; then echo "idle" > .client_status; fi
		# cat .client_status
}

set_status () {
		# TODO: use the map to set the status
		map_set_field "status" $1

		# if [ ! -f .client_status ]; then touch .client_status; fi
		# echo $1 > .client_status
}

shutdown_program () {
		# gracefully kills the script 
		# TODO: add the graceful part
		kill -KILL -$CLIENT_PID 2> /dev/null
		kill -KILL $CLIENT_PID
}

kill_task () {
		debug "killing process $(map_get_field "pid" )"
		echo "killing " $(map_get_field "pid")
		pkill -P $(map_get_field "pid")
		kill -KILL $(map_get_field "pid")
		set_status "idle"
}


handle_signal(){
		# if signal is stop kill the running process
		debug "having something like $1"
		debug "receiving signal $signal"
		case "$signal" in
				"kill") kill_task;;
				"wait") set_status "wait";;
				"shutdown") shutdown_program;;
				"resume") set_status "idle";;
		esac
}

# NOTE: not yet integrated 
get_cmd_stats (){
		# used to collect statistics for the
		# recently run command
		# it parses them in a json format to be
		# sent back to the server 
		stats=$(cat .cmd_stats)
		if [ ! -z $stats ]
		json_str="{"
		IFS=$'\n'
		then 
				for i in $stats
				do
						name=${i%:*}
						value=${i#*:}
						json_str="$json_str, \"$name\":$value"
				done
		json_str="$json_str }"
		fi

		# echo $json_str

		# remove the stats from the file 
		echo "" > .cmd_stats
}

parse_response (){
		# check if there is a debugging in the response
		# echo $resp
		debug=$(echo $resp | jq -r 'if .config?.debug? then "debug" else empty end')
		if [ ! -z $debug ]; then map_set_field "debug" "true"; fi
		# check for any signals from the server
		signal=$(echo $resp | jq -r 'if .config?.signal? then .config.signal else empty end')
		handle_signal 
		# check if 
}

# TODO: add more debugging code functions

set_script () {
		if [ ! -f .cmd_script ]
		then
				touch .cmd_script
				chmod +x .cmd_script
		fi

		echo "#!/bin/bash" > .cmd_script
		echo "source $ROOT_DIR/scripts/tools.sh" >> .cmd_script
		echo "ngrok_url=\"$ngrok_url\"" >> .cmd_script
		cat <<<"$cmd" >> .cmd_script
		
}


# shared varaibles 
STATUS=$(get_status )

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


sync_server() {
		# syncs the node with the server 
		ngrok_url=$(get_ngrok_url)
		echo $ngrok_url
		while [ ! -z "a" ]
		do
				# echo "syncing..."
				resp=$(curl  -s --request POST --data "{\"host\":\"$REMOTE_HOST\", \"id\": \"$1\", \"status\": \"$(get_status)\"}" "$ngrok_url/sync/"
							 
										
						);
				# handles the reponse and run the required functions
				parse_response

				# run the cmd 
				cmd="$(echo $resp | jq 'if .task then .task else empty end' | jq -r '.cmd?')"
				tsk_id="$(echo $resp | jq -r 'if .task.id then .task.id else empty end')"
				chunk="$(echo $resp | jq -r 'if .task.chunk then .task.chunk else empty end')"

				# debugging 

				# debug "server response: $resp"
				debug "node status: $(get_status) "
				debug "command:\n $(cat <<<$cmd)"

				if [ ! -z "$cmd" ]
				then

						# echo "$tsk_id"
						# echo "$chunk"
						map_set_field "id" "$tsk_id"
						map_set_field "chunk" "$chunk"
						set_script $cmd
						run_command 
						echo "$!" > .running_cmd_pid

				fi
				# NOTE: not yet integrated 
				get_cmd_stats
				# TODO: read the sleep from the server response 
				sleep 3

		done
}

run_command(){
		# runs the command coming from the server
		set_status "busy"
		run_cmd &
		kill -CONT $!
}

# check_status(){
# 		# checks the status of the server by
# 		# testing if the run_command function is
# 		# running or not 

# 		# MAYBE: use a variable that is set once the
# 		#      : the function enters and then reset 

# }

cleanup_after_cmd(){
		# commands to run just after running the
		# command 
		echo "" > .running_cmd_pid
		set_status "idle"
}

init_before_cmd() {
		# commands to run just before running the
		# command 
		echo "" > .cmd_stats
}

run_cmd (){
		init_before_cmd 
		./.cmd_script
		cleanup_after_cmd
}


cleanup(){
		# runs at the head of the server to cleanup
		# data from the previous runs 
		rm .cmd_stats
		rm .cmd_script
		rm .running_cmd_pid
		rm .client_status
		rm .status_map

		# init the map 
		map_set_field
}

# cleanup the previous data
cleanup

sid=$(gen_random_id)
REMOTE_HOST=$1
echo $sid
echo $REMOTE_HOST
sync_server $sid  


echo "node id: $sid"
echo "remote host: $REMOTE_HOST"
echo "remote host id: $HOST_ID"
echo "status_map: $status_file"
echo "script_file: $script_file"
echo "ngrok_url: $NGROK_URL"
sync_server $sid  
