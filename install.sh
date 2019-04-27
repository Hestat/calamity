#!/bin/bash

#create main install directory
mkdir -p /opt/calamity/work

maindir=/opt/calamity

#choose y/N to install
yesno(){ read -p "$question " choice;case "$choice" in y|Y|yes|Yes|YES ) decision=1;; n|N|no|No|NO ) decision=0;; * ) echo "invalid" && yesno; esac; }

##### formatting #####

#Creates variable for red color
red='\e[0;31m'
#Creates variable for bold red color
redbold='\e[1;31m'
#Creates variable for green color
green='\e[0;32m'
#Creates variable for yellow color
yellow='\e[1;33m'
#Creates variable for purple color
purple='\e[1;35m'
#Creates variable for no color
whi='\e[0m'
#blue
blue='\e[34m'


###Volatility install and updates###
volinstall(){
	pushd /opt/calamity
	git clone https://github.com/volatilityfoundation/volatility.git
	pip2 install -r volatility/requirements.txt
	popd
}

volupdate(){
	pushd /opt/calamity/volatility/
	git pull
	popd
}

###Loki install and updates###
lokiinstall(){
	pushd /opt/calamity
	git clone https://github.com/Neo23x0/Loki.git
	pip2 install -r Loki/requirements.txt
	python /opt/calamity/Loki/loki-upgrader.py
       	popd
}
lokiupdate(){
	pushd /opt/calamity/Loki
	git pull
	python /opt/calamity/Loki/loki-upgrader.py
	popd
}

###Malconfscan plugin###
malconfinstall(){
	pushd /opt/calamity
	git clone https://github.com/JPCERTCC/MalConfScan.git
	pip install -r MalConfScan/requirements.txt
	cp MalConfScan/malconfscan.py /opt/calamity/volatility/volatility/plugins/malware/
	cp -R MalConfScan/yara /opt/calamity/volatility/volatility/plugins/malware/
	cp -R MalConfScan/utils /opt/calamity/volatility/volatility/plugins/malware/
	popd
}
malconfupdate(){
	pushd /opt/calamity/MalConfScan
	git pull
	cp malconfscan.py /opt/calamity/volatility/volatility/plugins/malware/
	cp -R yara /opt/calamity/volatility/volatility/plugins/malware/
	cp -R utils /opt/calamity/volatility/volatility/plugins/malware/
	popd
}
	


if [[ -e /opt/calamity/volatility ]]; then #volatility installed run update
	echo -e "$green Volatility install found, running updates $whi"
	volupdate
else
	volinstall
	echo -e "$yellow Volatility not installed, proceeding to install $whi"
fi

if [[ -x $(which clamscan 2> /dev/null) ]]; then #clamav installed
	echo -e "$green\n Found ClamAV installed continuing\n$whi"
else
	echo -e "$redbold Please install ClamAV first, then run this script again\n $whi"
	exit 0
fi

if [[ -e /opt/calamity/Loki ]]; then #Loki installed run update
	echo -e "$green Loki installed running update $whi"
	lokiupdate
else
	echo -e "$yellow Loki not found installing $whi"
	lokiinstall
fi

if [[ -e /opt/calamity/MalConfScan ]];then #malconfscan installed run updates
	echo -e "$green MalConfScan installed running updates$whi"
	malconfupdate
else
	echo -e "$yellow MalConfScan not found installing...$whi"
	malconfinstall
fi

cp -av calamity /opt/calamity/calamity
chmod 755 /opt/calamity/calamity
ln -s /opt/calamity/calamity /usr/bin/calamity 2>/dev/null


