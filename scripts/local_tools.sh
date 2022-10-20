# * get domain 
# ** 

# make_task(){
# 		task=$(python3 /home/rese/bug-hunting/command_to_json.py --cmd "$@")
# 		curl --request POST --data "$task" "http://localhost:8020/tasks/add/"
# 		echo $task
# }

# TEST: testing without sending to the program 
make_task(){
		task=$(python3 /home/rese/bug-hunting/command_to_json.py --cmd "$@")
		echo $task
		curl --request POST --data "$task" "http://localhost:8020/tasks/add/"
}

# * check http servers
get_http_servers () {
		make_task gethttp \
							-I {{files1}} \
							-o {{files2}} \
							---files1 $(ls -1 *domain.txt) \
							---files2 $(ls -1 *domain.txt | sed -n 's/\-domain.txt$/-http.json/p')
}

rhttpx () {make_task gethttp $@}
		
# * spider http sites

rspider() {
		make_task gaufile \
							-i {{files1}} \
							-o {{files2}} \
							---files1 *-http.json \
							---files2 $(echo *-http.json | sed -n 's/-http\.json/-gau-urls.json/p') \
							---local false
							
		make_task spidersite \
							-i {{files1}} \
							-o {{files2}} \
							---files1 *-http.json \
							---files2 $(ls -1 *-http.json | sed -n 's/-http\.json/-gospider-urls.json/p') \
							---local false
}

# rgospider (){ make_task spidersite $@ }

# * check secrets, domains in js files and so on

get_secrets (){
		subdomainizer $@ 
		# TODO: more secrets
}


# * check technologies 
get_technologies () {
		wapp $@
}

# * others
# ** nuclei script 
# ** port scanning 
# ** vulnerabilities 
# *** sqlmap


get_http_servers
 
