#!/bin/bash


# use the content/bin in the path 
PATH="~/content/bin/:$PATH"

# TODO: create a storage-like dcitionary but with files
# TODO: use the status map to store everything 

map_get_field(){
		# DEBUG:
		case $1 in
				"id")
						cat .status_map | sed -n '1p'
						;;
				"chunk")
						cat .status_map | sed -n '2p'
						;;
				"status")
						cat .status_map | sed -n '3p'
						;;
		esac 
		
}

map_set_field (){
		if [ ! -f .status_map ]
		then
				echo "creating .status_map file "
				touch .status_map
				echo "testid" > .status_map
				echo "teststatus" >> .status_map
				echo "testchunk" >> .status_map
		fi
		
		case $1 in
				"id")
						sed -i "1 s/.*/$2/" .status_map
						;;
				"chunk")
						sed -i "2 s/.*/$2/" .status_map
						;;
				"status")
						sed -i "3 s/.*/$2/" .status_map
						;;

						# TODO: add more pairs
		esac 
		
}



gen_random_id(){
		echo $(hexdump -vn16 -e'4/4 "%08X" 1 "\n"' /dev/urandom)
		python3 -c 'from string import ascii_letters, digits; from random import choice;print("".join(choice (ascii_letters + digits) for i in range(32)))'
}

get_status(){
		if [ ! -f .client_status ]; then echo "idle" > .client_status; fi
		cat .client_status
}

set_status () {
		if [ ! -f .client_status ]; then touch .client_status; fi
		echo $1 > .client_status
}

shutdown_program () {
		# gracefully kills the script 
		# TODO: add the graceful part
		kill -KILL $$
}

kill_task () {
		kill -KILL $(cat .running_cmd_pid)
		set_status "idle"
		# TODO: change this to accomodate running multiple tasks
		echo "" > .running_cmd_pid
}


handle_signal(){
		# if signal is stop kill the running process
		case "$signal" in
				"kill")
						# handle kill
						kill_task
				;;
				"wait")
						# handle wait
						set_status "wait"
				;;
				"shutdown")
						# handle shutdown
						shutdown_program
				;;
				"resume")
						# handle resume
						set_status "idle"
				;;
		esac
}


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

		echo $json_str

		# remove the stats from the file 
		echo "" > .cmd_stats
}

parse_response (){
		# check if there is a debugging in the response
		debug=$(echo $resp | jq -r 'if .config?.debug? then "debug" else empty end' )
		# check if debugging and run debugging code 
		if [ ! -z $debug ]
		then
				run_debug
		fi

		# check for any signals from the server 
		signal=$(echo $resp | jq -r 'if .config?.signal? then .config.signal else empty end')
		handle_signal 
		# check if 
}

# TODO: add more debugging code functions
run_debug (){
		echo $resp
		echo "server response: $resp"
		status="node status: $(get_status) "
		echo $status
		
		if [ ! -z "$cmd" ]
		then
				echo -e "command:\n $(cat <<<$cmd)"
		fi
}


set_script () {
		if [ ! -f .cmd_script ]
		then
				touch .cmd_script
				chmod +x .cmd_script
		fi

		echo "ngrok_url=\"$ngrok_url\"" > .cmd_script
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



ngrok_url=$(get_ngrok_url)
sync_server() {
		# syncs the node with the server 
		ngrok_url=$(get_ngrok_url)
		while [ ! -z "a" ]
		do
				# echo "syncing..."
				resp=$(curl -s --request POST --data '{"host":"colab","status"'":\"$(get_status)\", \"id\":\"$1\"}" "$ngrok_url/sync/");
				# handles the reponse and run the required functions
				parse_response
				# run the cmd 
				cmd="$(echo $resp | jq 'if .task then .task else empty end' | jq -r '.cmd?')"
				tsk_id="$(echo $resp | jq -r 'if .task.id then .task.id else empty end')"
				chunk="$(echo $resp | jq -r 'if .task.chunk then .task.chunk else empty end')"
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
				get_cmd_stats
				sleep 3
		done
}

run_command(){
		# runs the command coming from the server
		set_status "busy"
		time run_cmd &
		kill -CONT $!
}

# check_status(){
# 		# checks the status of the server by
# 		# testing if the run_command function is
# 		# running or not 

# 		# MAYBE: use a variable that is set once the
# 		#      : the function enters and then reset 

# }
purge_after_cmd(){
		# does some cleanup after running
		# the command 
		echo "" > .running_cmd_pid
		set_status "idle"
}

run_cmd (){
		./.cmd_script
		purge_after_cmd
}

sid=$(gen_random_id)
echo $sid
sync_server $sid
