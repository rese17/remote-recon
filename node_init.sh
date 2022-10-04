
# make directory for binaries
# use a file to check if the init shit is finished 
mkdir content
cd content



# download stuff inside teh directory 
wget --quiet https://github.com/OWASP/Amass/releases/download/v3.19.3/amass_linux_amd64.zip -O amass.zip
wget --quiet https://github.com/projectdiscovery/nuclei/releases/download/v2.7.7/nuclei_2.7.7_linux_amd64.zip -O nuclei.zip 
wget --quiet https://github.com/projectdiscovery/naabu/releases/download/v2.1.0/naabu_2.1.0_linux_amd64.zip -O naabu.zip
wget --quiet https://github.com/projectdiscovery/httpx/releases/download/v1.2.4/httpx_1.2.4_linux_amd64.zip -O httpx.zip
wget --quiet https://github.com/lc/gau/releases/download/v2.1.2/gau_2.1.2_linux_amd64.tar.gz -O gau.tar.gz
wget --quiet https://github.com/jaeles-project/gospider/releases/download/v1.1.6/gospider_v1.1.6_linux_x86_64.zip -O gospider.zip
wget --quiet https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O jq; chmod +x jq 
wget --quiet https://github.com/tomnomnom/unfurl/releases/download/v0.4.3/unfurl-linux-amd64-0.4.3.tgz -O unfurl.tgz
wget --quiet https://pixeldrain.com/api/file/GibrBBs9 -O cariddi; chmod +x cariddi 
wget --quiet https://pixeldrain.com/api/file/PhBN89Sj -O domxss; chmod +x domxss 
wget --quiet https://github.com/ffuf/ffuf/releases/download/v1.5.0/ffuf_1.5.0_linux_amd64.tar.gz -O fuff.tar.gz

# unpack stuff 
unzip -o amass.zip; rm amass.zip
unzip -o nuclei.zip ; rm nuclei.zip
unzip -o naabu.zip ; rm naabu.zip
unzip -o httpx.zip ; rm httpx.zip
tar -xf gau.tar.gz ; rm gau.tar.gz
tar -xzf unfurl.tgz; rm unfurl.tgz
tar -xzf fuff.tar.gz; rm fuff.tar.gz; chmod +x fuff;  
unzip -o gospider.zip; rm gospider.zip

# get all executables from inner directories 
mkdir bin
find . -type f -not -path "./bin/*"  -executable -exec mv {} ./bin/ \;
find . -not -path "./bin*" -exec rm -rf {} \;


# get python git packages 
mkdir github
git clone https://github.com/s0md3v/XSStrike github/ 
echo -e "#!/bin/dash\npython3 \n python github/XSStrike/xsstrike.py $@" > bin/xsstrike; chmod +x bin/xsstrike;
git clone https://github.com/m4ll0k/Atlas.git github/atlas
echo -e "#!/bin/dash\npython3 \n python github/atlas/atlas.py $@" > bin/atlas; chmod +x bin/atlas;
echo "there in this shit "


# fuzzing and payloads 
mkdir payloads 
mkdir payloads/vuln-payloads
cd payloads; git clone https://github.com/swisskyrepo/PayloadsAllTheThings;

# get python pip packages  
pip install wfuzz
pip install dirsearch
pip install sqlmap
pip install wafw00f
pip install xsstrike
pip install photon
pip install arjun
pip install s3recon


## finally link everything in the /notebooks/bin/ directory to the /usr/local/bin
ln -s -f $(pwd)/bin/* /usr/local/bin/

echo "init finished" > .init_finished



# pastebin syncing 
api_user_key=$(curl -s -X POST -d 'api_dev_key=hizd6zKuf1leXglo1nYvDzG_u0_zsf8U' -d 'api_user_name=ntrysii' -d 'api_user_password=QntsXhDLdNbYf^wbrUsq5' "https://pastebin.com/api/api_login.php")
curl -s -X POST -d 'api_dev_key=hizd6zKuf1leXglo1nYvDzG_u0_zsf8U' -d "api_user_key=$api_user_key"  -d 'api_paste_key=4ZU4ZKja' -d 'api_option=show_paste'  "https://pastebin.com/api/api_post.php" > client.sh
chmod +x client.sh 
sed -i 's/\r//' client.sh

pastebin_create_file(){;}
pastebin_delete_file(){;}
pastebin_update_file (){;}
pastebin_get_file(){;}

download_scripts(){;}



echo "this is the new line that im adding"
