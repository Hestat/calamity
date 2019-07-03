## Calamity

```
================================================================================

      ========================= Calamity =========================

A script to assist in processing forensic RAM captures for malware triage

Run the script with no options and it will run in guided mode prompting the
user to choose options as required

If you already know the correct volatility memory profile you can use the
following options
 -f --filepath provide the complete filepath to the RAM memory dump
 -p --profile provide the memory provile you want volatility to use
 -s --scan will run all scans and prompt user as required
 -q --quick will run a quick scan for malware, no user input required to complete
 -c --config same as quickscan but will try to extract malware configurations as well

Example:
calamity -f /home/user/memory.dmp -p Win10x64_10586 -s

calamity --fullpath /home/user/memory.dmp --profile Win10x64_10586 --scan

================================================================================

```
Full walkthrough and writeup:
https://laskowski-tech.com/2019/05/18/calamity-a-volatility-script-to-aid-malware-triage/


Original inspiration to Volatility Labs writeup in this article:
https://volatility-labs.blogspot.com/2016/08/automating-detection-of-known-malware.html

Which led me to write up my version:
https://laskowski-tech.com/2019/02/18/volatility-workflow-for-basic-incident-response/

Which led to this project. Good Hunting.

Install instructions:

On base system (has been tested for Ubuntu, Kali)

```
git clone https://github.com/Hestat/calamity.git
cd calamity
sudo ./install.sh
```

Docker option:

```
docker pull hestat/calamity

docker run --rm -it -v ~/memory-dumps:/home/nonroot/memdumps hestat/calamity:latest bash
```

The /memory-dumps folder is where the memory images reside on the host OS, you will be dropped into a bash shell in the home directory of the nonroot user with a folder called memdumps which is mapped to the folder on the host OS. 


