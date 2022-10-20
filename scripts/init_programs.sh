#!/bin/bash


# NOTE: use the root directory for all newly added scripts
if [ ! -d $ROOT_DIR/scripts/SubDomainizer ]; then
		git clone https://github.com/nsonaniya2010/SubDomainizer $ROOT_DIR/scripts/SubDomainizer/;
		python3 -m pip install -r $ROOT_DIR/scripts/SubDomainizer/requirements.txt
fi



# ** programs
# *** spidering



# *** subdominizer
run_subdominizier(){
		# install 
		
		python3 SubDomainizer/SubDomainizer.py -u $1 -o .subdom_output -cop .subdom_cloud -gop .subdom_github -k -gt "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" -g > /dev/null
		# files to json
		python3 entry_to_json.py .subdom_output "domain" $1
		python3 entry_to_json.py .subdom_cloud "cloud" $1
		python3 entry_to_json.py .subdom_github "github" $1
}

# *** 

