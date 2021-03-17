#!/bin/bash
########################################################################
#Log
LOG_FILE=migration.log.$(date +%F_%R)
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)
########################################################################

echo -e "Script will transfer remote server account to thsi server\n"
echo -e "\n"
echo -e " Time the script started : $(tput setaf 1) `date` $(tput sgr 0)"
script_date=`date`
echo -e "\n"
echo -e "Enter the remote server IP Address\n"
read -e ipaddr
echo -e "Checking the .ssh/id_rsa.pub file stat\n"
if [ -f .ssh/id_rsa.pub ]
then
echo -e "key already exists.. opening the key file .ssh/id_rsa.pub\n"
echo -e "Copying the key file to the remote server\n"
ssh-copy-id root@$ipaddr
else
echo -e "Genearating ssh key\n"
ssh-keygen
ssh-copy-id root@$ipaddr
fi

##########################################################################
echo -e "$(tput setaf 1)Checking the compactability of both server$(tput sgr 0)\n"
echo -e "$(tput setaf 2)Remote server$(tput sgr 0)"
echo -e "---------------"
ssh -qt root@$ipaddr 'echo -e "httpd"
echo  "---------"
httpd -v
echo -e " "
echo -e "mysql"
echo  "---------"
mysqladmin --version
echo -e " "
echo -e "PHP"
echo  "---------"
php -v
echo -e " "
echo -e "CPANEL VERSION"
echo  "---------"
cat /usr/local/cpanel/version
echo -e "Disk space Stat  ----------------------> Verify the disk stat before proceeding"
echo  "-------------"
df -h'
echo -e "\n"

echo -e "$(tput setaf 2)Current server$(tput sgr 0)"
echo -e "httpd"
echo  "---------"
httpd -v
echo -e " "
echo -e "mysql"
echo  "---------"
mysqladmin --version
echo -e " "
echo -e "PHP"
echo  "---------"
php -v
echo -e " "
echo -e "CPANEL VERSION"
echo  "---------"
cat /usr/local/cpanel/version
echo -e "Disk space Stat ----------------------> Verify the disk stat before proceeding"
echo  "-------------"
df -h
echo  -e " "
read -n 1 -s -r -p "Press any key to continue with easyapache checking"
############################################################################

echo -e "$(tput setaf 1)\n\n EASYAPACHE 3 & 4 CHECKING$(tput sgr 0)\n"
ssh -qt root@$ipaddr 'echo -e "Checking the easyapache differences between server\n"
if [ -f /var/cpanel/easy/apache/profile/_main.yaml ]
then
echo -e "Source server is easy apache 3\n"
echo -e "Generating json file of the profile\n"
/scripts/convert_ea3_profile_to_ea4 /var/cpanel/easy/apache/profile/_main.yaml support.json
else
echo -e "Source server and destination server have ea4\n"
echo -e "Generating json file of the profile\n"
/usr/local/bin/ea_current_to_profile --output=support.json
fi'
echo -e "Json file generated\n"
echo -e "Copying to the destination server\n"
mkdir -p /etc/cpanel/ea4/profiles/custom/
scp root@$ipaddr:support.json /etc/cpanel/ea4/profiles/custom/
echo -e "Copying compeleted running the easyapache using new json profile\n"
/usr/local/bin/ea_install_profile --install /etc/cpanel/ea4/profiles/custom/support.json
echo -e "\n"
echo -e "$(tput setaf 1) Easy Apache 4 recompilation completed$(tput sgr 0)\n"
echo -e " "
read -n 1 -s -r -p "Press any key to continue with generating account list"
#################################################################################


echo -e "$(tput setaf 1)\n\nGetting account details from remote server$(tput sgr 0)\n"
ssh -qt root@$ipaddr 'echo -e "$(tput setaf 2)Account List$(tput sgr 0)"
echo -e "-------------"
cat /etc/trueuserdomains
echo -e " "
echo -e "Total number of Accounts)"
echo -e "-------------"
cat /etc/trueuserdomains | wc -l
echo -e " "'
echo -e "$(tput setaf 1\n\n)Generating backup of all the accounts in remote$(tput sgr 0)"
ssh -qt root@$ipaddr 'mkdir -p migratekvm
cat /etc/trueuserdomains | cut -d  " " -f2 | while read i ; do /scripts/pkgacct --skiphomedir $i /root/migratekvm/ ; done'
echo -e "$(tput setaf 2) Backup generation completed $(tput sgr 0)"
echo -e "\n"
echo -e "$(tput setaf 2) Getting backup list $(tput sgr 0)\n"
################################################################################

ssh -qt root@$ipaddr 'ls -la /root/migratekvm/'
echo -e "\n"
read -n 1 -s -r -p "Press any key to continue with copying the backup file"
echo -e "$(tput setaf 1)\n\n Starting with copying the backup files$(tput sgr 0)"
rsync -avzP -e "ssh -i .ssh/id_rsa" root@$ipaddr:/root/migratekvm /root/
echo -e "\n"
echo -e "$(tput setaf 2) Getting list of backup files copied $(tput sgr 0)\n"
ls -la /root/migratekvm/
echo -e "\n"
#################################################################################

echo -e "$(tput setaf 1)\n\n Starting with the restoration of the accounts $(tput sgr 0)"
ls -la /root/migratekvm/ | grep cpmove | awk '{print $9}' | while read i; do /scripts/restorepkg /root/migratekvm/$i ; done
echo -e "\n"
echo "$(tput setaf 2) Restoration of accounts without homedir compelted $(tput sgr 0)"
echo -e "\n"
##################################################################################

echo -e "$(tput setaf 2)\n\n Continue with syncing the homedir $(tput sgr 0)"
ls -la /root/migratekvm/ | grep cpmove | awk '{print $9}' | cut -d '-' -f2 | cut -d '.' -f1 | while read i; do rsync -avzP -e "ssh -i .ssh/id_rsa" root@$ipaddr:/home/$i/ /home/$i/ ; done
echo -e "\n"
echo -e "$(tput setaf 1) Home directory sync completed $(tput sgr 0)"
echo -e "\n"
echo -e "Running fix quota \n"
/scripts/fixquotas
echo -e "Quota fixed \n"
#################################################################################

echo -e "$(tput setaf 1) Comparing the httpd Module : Below is the list of module that present in old and not in the new server, If the list is empty all module in old server is setup in new server $(tput sgr 0)\n"
ssh -qt  root@$ipaddr 'httpd -M | cut -d " " -f2 ' > rem_mod
httpd -M | cut -d ' ' -f2 > curr_mod
cat rem_mod |  grep -vf curr_mod > cha_http
cat cha_http | grep -iv Syntax | grep -iv "NameVirtualHost"
echo -e "\n"
echo -e "$(tput setaf 1) Comparing the PHP Module : Below is the list of module that present in old and not in the new server, If the list is empty all module in old server is setup in new server $(tput sgr 0)\n"
ssh -qt  root@$ipaddr 'php -m ' > rem_mod
php -m  > curr_mod
cat rem_mod | grep -vf curr_mod > cha_php
cat  cha_php
rm -rf rem_mod curr_mod
#####################################################################################

echo -e "\n"
echo -e "--------------------------"
echo -e " Time the script started : $(tput setaf 1) $script_date $(tput sgr 0)"
echo -e " Time the script completed : $(tput setaf 1) `date` $(tput sgr 0)"
echo -e "--------------------------"
echo -e "\n"
echo -e "$(tput setaf 1) Process completed ! Cheerrssss... $(tput sgr 0)"
