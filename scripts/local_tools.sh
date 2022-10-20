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
							---files2 $(ls -1 *domain.txt | sed -n 's/\-domain.txt$/-http.json/p') \
}

rhttpx () {make_task gethttp $@}
		
# * spider http sites

rspider() {
		# TODO: create the http.txt file
		make_task gaufile \
							-i {{files1}} \
							-o {{files2}} \
							---files1 *-http.txt \
							---files2 $(echo *-http.txt | sed -n 's/-http\.txt/-gau-urls.json/p') \
							# ---remote-only 
							
		make_task spidersite \
							-I {{files1}} \
							-o {{files2}} \
							---files1 *-http.txt \
							---files2 $(ls -1 *-http.txt | sed -n 's/-http\.txt/-gospider-urls.json/p') \
							# ---remote-only
}

# rgospider (){ make_task spidersite $@ }

# * check secrets, domains in js files and so on

get_secrets (){
		echo $@
		make_task subdomainizer \
							-i {{list1}} \
							-o {{files2}} \
							---list1 *-http.txt \
							---files2 $(echo *-http.txt | sed -n 's/-http\.json/-subdominizer.json/p') \
							---remote-only \
							---active-nodes 10
		
		
		# TODO: more secrets
}


# * check technologies 
get_technologies () {
							-i {{list1}} \
							-o {{files2}} \
							---list1 *-http.txt \
							---files2 $(echo *-http.txt | sed -n 's/-http\.json/-subdominizer.json/p') \
							---local false
		wapp   
}

# * others
# ** nuclei script 
# ** port scanning 
# ** vulnerabilities 
# *** sqlmap

 

rspider

