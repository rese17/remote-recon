
#!/bin/bash



# * init the environment (download programs and so on)
source $ROOT_DIR/scripts/init_programs.sh

run_subdominizier(){
		# install 
		
		python3 $ROOT_DIR/SubDomainizer/SubDomainizer.py -u $1 -o .subdom_output -cop .subdom_cloud -gop .subdom_github -k -gt "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" -g > /dev/null
		# files to json
		python3 $ROOT_DIR/scripts/entry_to_json.py .subdom_output "domain" $1
		python3 $ROOT_DIR/scripts/entry_to_json.py .subdom_cloud "cloud" $1
		python3 $ROOT_DIR/scripts/entry_to_json.py .subdom_github "github" $1
}

# subdominizer 
subdomainizer() {
		
		while getopts "I:i:o:" opt; do
				case "${opt}" in 
						i) file=$OPTARG;;
						I) file=$OPTARG;;
						o) output=$OPTARG;;
						# TODO: adding threading and so on
				esac
		done
		for i in $(cat $file); do run_subdominizier $i >> $output; done 
}

# wapplyzer
wapp () {
	while getopts ":i:o:" opt; do
				case "${opt}" in 
						i) file=$OPTARG;;
						o) output=$OPTARG;;
						# TODO: adding threading and so on
				esac
		done	
	# run wapplyzer 
	for i in $file; do wappalyzer -r -p $i >> $output; done 
}

# whatweb
wweb() {
		while getopts ":i:o:" opt; do
				case "${opt}" in 
						i) file=$OPTARG;;
						o) output=$OPTARG;;
						# TODO: adding threading and so on
				esac
		done

		whatweb -i $file 
}
# MAYBE: install subdomainizer here 

# httpx
gethttp () {
		while getopts "I:i:o:" opt; do
				case "${opt}" in 
						I) file=$OPTARG;;
						i) file=$OPTARG;;
						o) output=$OPTARG;;
						# TODO: adding threading and so on
				esac
		done

		httpx -l $file \
					-title -sc -location  \
					-follow-redirects \
					-p 80,443,8080,8000,8443 \
					-rlm 4000 \
					-http2  \
					-json  \
					-o $output
}


# gau
gaufile () {
		while getopts "I:i:o:" opt; do
				case "${opt}" in 
						i) file=$OPTARG;;
						I) file=$OPTARG;;
						o) output=$OPTARG;;
						# TODO: adding threading and so on
				esac
		done
		for i in $(cat $file)
		do
				gau --json --subs $i >> $output
		done 
}

# gospider 
spidersite () {
		while getopts "I:i:o:" opt; do
				case "${opt}" in 
						i) file=$OPTARG;;
						I) file=$OPTARG;;
						o) output=$OPTARG;;
						# TODO: adding threading and so on
				esac
		done		

		gospider -S $file -q --js --include-subs --json >> ${output}
}


