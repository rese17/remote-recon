#!/bin/bash


# NOTE: use the root directory for all newly added scripts
if [ ! -d $ROOT_DIR/scripts/SubDomainizer ]; then
		git clone https://github.com/nsonaniya2010/SubDomainizer $ROOT_DIR/scripts/SubDomainizer/;
		python3 -m pip install -r $ROOT_DIR/scripts/SubDomainizer/requirements.txt
fi



# ** programs
# *** spidering



# *** subdominizer


# *** 

