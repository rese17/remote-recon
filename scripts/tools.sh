
#!/bin/bash



# * init the environment (download programs and so on)
source ~/remote-recon/scripts/init_programs.sh
echo "here in tools"
# subdominizer 
subdomainizer() {
		
		while getopts ":i:o:" opt; do
				case "${opt}" in 
						i) file=$OPTARG;;
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
		while getopts ":i:o:" opt; do
				case "${opt}" in 
						i) file=$OPTARG;;
						o) output=$OPTARG;;
						# TODO: adding threading and so on
				esac
		done
		for i in $(cat $file)
		do
				gau -json -subs $i >> $output
		done 
}

# gospider 
spidersite () {
		while getopts ":i:o:" opt; do
				case "${opt}" in 
						i) file=$OPTARG;;
						o) output=$OPTARG;;
						# TODO: adding threading and so on
				esac
		done		

		gospider -S $file -q --js --include-subs --json >> ${output}

}
