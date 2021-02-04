#!/bin/bash

#echo "Hello World"

vol=/opt/calamity/volatility/vol.py

mkdir /tmp/caltmp 2>/dev/null

pslog=/tmp/caltmp/pslist.log
netlog=/tmp/caltmp/netscan.log

rm /tmp/caltmp/* 2>/dev/null

###############################setup##################################
#choose y/N
yesno(){ read -p "$question " choice;case "$choice" in y|Y|yes|Yes|YES ) decision=1;; n|N|no|No|NO ) decision=0;; * ) echo "invalid" && yesno; esac; }


######################   create formatting #################################
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

div(){
  for ((i=0;i<$1;i++)); do printf '='; done;
}

header(){
	echo -e "\n$(div 80)\n"
}

header2=$(echo -e "$(div 3)")

########################################################################

helpmenu(){
	header
	echo -e "      =========================$red Calamity $whi=========================$whi"
	echo -e "$green\nA script to assist in processing forensic RAM captures for$red malware triage$whi\n"
	echo -e "Run the script with no options and it will run in guided mode prompting the\nuser to choose options as required"
	echo -e "\nIf you already know the correct volatility memory profile you can use the\nfollowing options"
	echo -e " -f, --filepath  provide the complete filepath to the RAM memory dump"
	echo -e " -p, --profile   provide the memory profile you want volatility to use"
	echo -e " -s, --scan      will run all scans and prompt user as required"
	echo -e " -q, --quick     will run a quick scan for malware, no user input required to complete"
	echo -e " -c, --config    same as quickscan but will try to extract malware configurations as well"
	echo -e "\nExample:\ncalamity -f /home/user/memory.dmp -p Win10x64_10586 -s"
	echo -e "\ncalamity --fullpath /home/user/memory.dmp --profile Win10x64_10586 --scan"
	header
}

########################################################################
main(){
yesno; if [ $decision = 1 ];then
	echo -e "$green Continuing to dump files from memory\n $whi"
else
	rm $pslog
	rm $netlog
	firstpass
	confirmpass
	echo -e "\n$yellow Does this output look correct? [y/n]"
	yesno; if [ $decision = 1 ]; then
		echo -e "$green Continuing to dump files from memory $whi\n"
		else
			rm $pslog
			rm $netlog
			firstpass
			confirmpass
			echo -e "$yellow Does this output look correct? [y/n]"
			yesno; if [ $decision = 1 ]; then
			echo -e "$green Continuing to dump files from memory $whi"
			else
			echo -e "$red Three strikes and you're out please try again $whi"
			exit 0
			fi
	fi
fi

echo -e "Create a case file, this folder will be created in the user home dir"
read casefolder

mkdir -p $HOME/$casefolder

casefolder2=$HOME/$casefolder

echo -e "$casefolder2"

echo -e "Would you like to perform a quickscan for malicious content? [y/n]"
yesno; if [ $decision = 1 ]; then
	mvlive
	mkdir $casefolder2/malfind
	vol-mal
	vol-cmd
	echo -e "$yellow\nMalfind command complete scanning contents...$whi"
	clam
	lokiscan
	processresults
	exit 0
else
	echo -e "Skipping quickscan"
fi

echo -e "$red\nWould you like to perform comprehensive scan? This can take a long time 1-8 hours [y/n]"
yesno; if [ $decision = 1 ];then
	#check for diskspace
	diskcheck=$(df $HOME | awk '{print$4}' | tail -n1)
	imagecheck=$(du -sx $inspect)
	if [ $imagecheck > $diskcheck ];then
	       echo -e "$red\nNot enough disk space to dump files from image, please clear disk space before completing this action $whi"
	       exit 0
       else
	       mvlive
	       mkdir $casefolder2/malfind
	       mkdir $casefolder2/dlldump
	       mkdir $casefolder2/moddump
		vol-mal
		vol-cmd
		vol-dll
		vol-sys
		echo -e "$yellow File dumps from image complete, starting scan"
		clam
		lokiscan
		processresults
	fi
else
	echo -e "$red\nExiting..."
	exit 0
fi
}


vol-mal(){
	python $vol --profile=$pickedprofile -f $inspect malfind -D $casefolder2/malfind --output-file=$casefolder2/malfind.log
}

vol-confscan(){
	for pid in $(grep Pid $casefolder2/malfind.log | egrep -v "MsMpEng.exe|smartscreen|mmc.exe" |awk '{print$4}'| sort | uniq); do timeout 300 python $vol --profile=$pickedprofile -f $inspect malconfscan -p $pid;done
}

vol-confscan2(){
	for pid in $(awk '{print$3}' clamprocs.log 2>/dev/null); do timeout 300 python $vol --profile=$pickedprofile -f $inspect malconfscan -p $pid;done
}

vol-cmd(){
	python $vol --profile=$pickedprofile -f $inspect cmdline --output-file=$casefolder2/commandline.log
}

vol-sys(){
	python $vol --profile=$pickedprofile -f $inspect moddump -D $casefolder2/moddump
}

vol-dll(){
	python $vol --profile=$pickedprofile -f $inspect dlldump -D $casefolder2/dlldump
}

clam(){
	clamscan -ir --no-summary $casefolder2/ | tee -a $casefolder2/clamavresults.log
}

lokiscan(){
	python /opt/calamity/Loki/loki.py --dontwait -l $casefolder2/lokiresults.log -p $casefolder2
}

mvlive(){
	cp -av $pslog $casefolder2/
	cp -av $netlog $casefolder2/
}

processresults(){
	pushd $casefolder2
	touch calamity.log
	header >> calamity.log
	echo -e "memory inspected using the following profile: $pickedprofile" >> calamity.log
	echo -e "$yellow===ClamAV results===$whi" | tee -a calamity.log
	cat clamavresults.log 2>/dev/null| tee -a calamity.log
	for i in $(cat clamavresults.log 2>/dev/null| cut -d . -f2 | uniq); do grep $i pslist.log >> $casefolder2/clamprocs.log;done
	echo -e "$red===Identified Malicious Processes===$whi" |tee -a calamity.log
	cat clamprocs.log 2>/dev/null | tee -a calamity.log
	echo -e "$red===Suspect Network Traffic from malicious Processes===$whi" | tee -a calamity.log
	for i in $(awk '{print$3}' clamprocs.log 2>/dev/null); do grep $i netscan.log | tee -a calamity.log;done
	echo -e "$yellow===Loki Results===$whi" | tee -a calamity.log
	grep FileScan lokiresults.log 2>/dev/null | tee -a calamity.log
	for i in $(grep FileScan lokiresults.log | cut -d . -f2); do grep $i pslist.log >> lokiprocs.log;done
	echo -e "$red===Identified Malicious Processes===$whi" | tee -a calamity.log
	cat lokiprocs.log 2>/dev/null | tee -a calamity.log
	echo -e "$red===Suspect Network Traffic from malicious Processes===$whi" | tee -a calamity.log
	for i in $(awk '{print$3}' lokiprocs.log 2> /dev/null); do grep $i netscan.log | tee -a calamity.log;done
	header >> calamity.log
	echo -e "$red===Suspicious Command Line Processes===$whi" | tee -a calamity.log
	egrep -i -A 1 -B 2  "SQB|-NoP|-NonI|-w Hidden" commandline.log | tee -a calamity.log
	header >> calamity.log
	popd
}

configscan(){
	echo -e "$yellow===Looking at Malfind Results for possible  malware configurations===$whi" | tee -a $casefolder2/calamity.log
	vol-confscan | tee -a $casefolder2/calamity.log
	vol-confscan2 | tee -a $casefolder2/calamity.log
}

########################################################################
#Advanced mode
########################################################################

# read the options
TEMP=`getopt -o f:p:s::q::c::h:: --long filepath:,profile:,scan::,quick::,config::,help:: -- "$@"`

eval set -- "$TEMP"

while true; do
	case "$1" in
		-h|--help)
			helpmenu
			exit 0;;
		-f|--filepath)
			inspect=$2; shift 2;;
		-p|--profile)
			pickedprofile=$2; shift 2;;
		-s|--scan)
			python $vol --profile=$pickedprofile -f $inspect pslist --output-file=/tmp/caltmp/pslist.log
			python $vol --profile=$pickedprofile -f $inspect netscan --output-file=/tmp/caltmp/netscan.log
			echo -e "$yellow\nParameters Entered would you like to continue? [y/n]"
			main
			exit 0;;
		-q|--quick)
			python $vol --profile=$pickedprofile -f $inspect pslist --output-file=/tmp/caltmp/pslist.log
			python $vol --profile=$pickedprofile -f $inspect netscan --output-file=/tmp/caltmp/netscan.log
			casefolder=calamity-quickscan$(date +%y%m%d-%H%M)
			mkdir -p $HOME/$casefolder
			casefolder2=$HOME/$casefolder
			echo -e "$yellow\nWriting logs to $casefolder2...$whi"
			mvlive
			mkdir $casefolder2/malfind
			vol-mal
			vol-cmd
			echo -e "$yellow\nMalfind command complete scanning contents...$whi"
			clam
			lokiscan
			processresults
			exit 0;;
		-c|--config)
			python $vol --profile=$pickedprofile -f $inspect pslist --output-file=/tmp/caltmp/pslist.log
			python $vol --profile=$pickedprofile -f $inspect netscan --output-file=/tmp/caltmp/netscan.log
			casefolder=calamity-quickscan$(date +%y%m%d-%H%M)
			mkdir -p $HOME/$casefolder
			casefolder2=$HOME/$casefolder
			echo -e "$yellow\nWriting logs to $casefolder2...$whi"
			mvlive
			mkdir $casefolder2/malfind
			vol-mal
			vol-cmd
			echo -e "$yellow\nMalfind command complete scanning contents...$whi"
			clam
			lokiscan
			processresults
			configscan
			exit 0;;


		* ) break;;
	esac
done





########################################################################
#Walk Through mode
########################################################################
echo -e "$yellow What is the path to the image to inspect? $whi\n"
read inspect

python $vol -f $inspect imageinfo --output-file=/tmp/caltmp/imageinfo.log 2>/dev/null

firstpass(){
	echo -e "\n$yellow Please pick the profile you would like to apply to this investigation\n $whi"
	grep Suggested /tmp/caltmp/imageinfo.log
	echo -e
	read pickedprofile

	echo -e "$yellow\n===Preparing to perform investigation===\n$whi"
	python $vol --profile=$pickedprofile -f $inspect pslist --output-file=/tmp/caltmp/pslist.log

	python $vol --profile=$pickedprofile -f $inspect netscan --output-file=/tmp/caltmp/netscan.log
}

firstpass

confirmpass(){
	echo -e "\n$yellow Please review the output from the Running Processes and Network connections to see if profile is correct. \n$whi"
	read -p "Press enter to continue"
	less $pslog
	less $netlog
}

confirmpass

echo -e "$yellow Does this output look correct? [y/n]"

main
