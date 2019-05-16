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

Original inspiration to Volatility Labs writeup in this article:
https://volatility-labs.blogspot.com/2016/08/automating-detection-of-known-malware.html

Which led me to write up my version:
https://laskowski-tech.com/2019/02/18/volatility-workflow-for-basic-incident-response/

Which led to this project. Good Hunting.
