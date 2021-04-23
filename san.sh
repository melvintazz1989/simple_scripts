#/bin/bash
#Log
# Read ME INFO
#Steps that scripts do
#Shows all the Disk Block on server
#Shows the Disk which are already mounted
#Script will ask you to update the Disk that needs to be mounted : Ex /dev/vdc
#Script will ask you for the mounting point : For Ex: /home
#Script will check if the mounting point has any data in it and it is already mounted. If it has data above 17MB then the script will exit or if the mounting point is already in fstab then the script will go to the next script asking if we need to unmount the Disk
#If the Directory does not have any data and mount point is not in fstab then it will start the mounting process
#Creating file system for the Disk Block
#Mounting and updating the New Block Id to fstab
#The Script does create logs under /root/mount. (Ex :/root/mount_log.$(date +%F_%R )
LOG_FILE=/root/mount_log.$(date +%F_%R)
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)
##############################################################################################
banner()
{
  echo "+-------------------------------------------------------------------------------------------------------------------+"
  printf "`tput bold` %-80s `tput sgr0`|\n" "$@"
  echo "+-------------------------------------------------------------------------------------------------------------------+"
}
#############################################################################################
banner "Welcome to SAN Mounting"
sleep 3
#####################Color Code#############################################################
red=$(tput setaf 1)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
reset=$(tput sgr 0)
############################################################################################
banner "$yellow >>>>>>>>> Starting the Mounting Process <<<<<<<<< $reset"
echo -e "*)Please make sure /home or /backup are already backed"
echo -e "*)Please make sure to create a mount diretcory"
echo -e "\n"
echo -e "Press "$red yes $reset" if you have already done the above"
read -e yes;
if [ $yes == yes ]
then
banner "$red Determining the Block Disk on the server$reset"
lsblk | grep vd
echo -e "\n"
echo -e "\n"
banner "$(tput setaf 1)Determining the Block Disk which are already mounted$(tput sgr 0)"
df -h | grep dev
echo -e "\n"
echo -e "\n"
sleep 4
echo -e "$(tput setaf 1)Please Enter the Block Disk which need to be mounted: for example >> /dev/vdc$(tput sgr 0)";
read -e disk;
echo -e "\n"
echo -e "\n"
echo -e "$(tput setaf 1)Location of the diretory in which you need to mount the DISK$(tput sgr 0)";
read -e loc;
chec=`du -sc $loc | grep -v "total" | awk '{print $1}'`
echo -e "\n"
banner "Verification Starts for Mounting Point and the Disk"
echo -e "\n"
echo -e "$(tput setaf 1)Checking if the Mounting location exist and if the mounting location has any data$(tput sgr 0)";
if [ -z `du -sch $loc | grep -v "total" | awk '{print $2}'` ]
then
echo -e "\n"
echo -e "$(tput setaf 1)Directory is not yet created please create the directory and restart the script again$(tput sgr 0)";
echo -e "$(tput setaf 1)Exiting the script$(tput sgr 0)"
exit 1
elif [ $chec -gt 17516 ];
then
echo -e "\n"
banner "There are more than 17MB Disk usage in the directory. Please cross verify and make sure that the mounting point is not having any data"
echo -e "\n"
echo `du -sch $loc`
echo -e "Exiting the Script";
exit 1
else
echo "The directory not having any data"
echo -e "\n"
banner "$green Directory is already created you are good to start the mounting $reset"
du -sch $loc
fi
echo -e "\n"
echo -e "\n"
echo "$green Mounting Disk is=$disk $reset"
echo "$green Location to which the Disk is mounted=$loc $reset";
echo -e "\n"
read -n 1 -s -r -p "$red Press Enter if this is correct--->(Press "Control+c" to stop the script)$reset";
echo -e " ";
echo -e "\n"
echo -e "$red Please cross verify if the Block is >> $disk $reset";
check=`df -h | grep "$disk"`
if [ -z `df -h | grep "$disk" | awk '{print $1}'` ]
then
echo -e "\n"
echo -e "$green This device is not mounted to any MOUNTPOINT $reset";
echo -e "\n"
banner "$green Now it is time to make file system in the $disk $reset"
read -n 1 -s -r -p "$red Press Enter to start the process $reset";
echo -e "$red Making the File System: $reset";
mkfs -t ext4 $disk
echo -e "$green Sucessfully created the Files System $reset";
echo -e "\n"
echo -e "$green The disk details: \n $blkid $reset";
blkid=`blkid | grep $disk`
UUID=`blkid | grep $disk | awk {'print $2'}`
OnUUID=`blkid | grep $disk | cut -d '"' -f 2`
echo -e "$OnUUID";
echo -e "The disk details: \n $blkid";
echo -e "\n"
banner "$green Mounting the Disk $disk to $loc $reset"
read -n 1 -s -r -p "$red Press Enter to mount the Disk $reset";
mount $disk $loc
echo -e "$green Mounting completed $reset";
echo -e "$green Verifying the mounting is correct $reset";
echo -e "\n"
lsblk | grep $loc
echo -e "\n"
df -h | grep $loc
echo -e "\n"
banner "$green Everything looks fine. Now script will update these in fstab $reset"
cp -pr /etc/fstab /etc/fstab.$(date +%F_%R)
if [ -z `grep $UUID /etc/fstab` ]
then
echo -e "\n"
echo -e "Device is not added to fstab";
echo -e "\n"
echo -e "Adding the below entry in fstab";
echo -e "UUID=$OnUUID  $loc  ext4 defaults 0 0";
echo -e "\n"
read -n 1 -s -r -p "Press $red Enter $reset to append the above details to fstab";
echo UUID=$OnUUID  $loc  ext4 defaults 0 0 >> /etc/fstab
echo -e "Verifying the Entry"
grep -ir $UUID /etc/fstab
echo -e "\n"
banner "Running mount -a. If it pops up any error then please manually check fstab entry"
mount -a
mount -v
sleep 4
echo -e "\n"
echo -e "\n"
banner "$green Completed----------------Now please start the data Transfer $reset"
lsblk | grep $loc
else
echo -e "Device is already added to fstab:: Need to modify it";
sed -i '/UUID='$OnUUID'/ c\UUID='$OnUUID'  '$loc'  ext4 defaults 0 0' /etc/fstab
grep -r $loc /etc/fstab
echo -e "$yellow ##################################################################$reset";
echo "Completed"
lsblk | grep $loc
echo -e "$yellow ##################################################################$reset";
fi
else
banner "$red This Device $disk is already mounted to \n $check $reset"
echo -e "\n"
echo -e "Do you need to Unmount the curreent location and start mounting the Disk to a New location"
echo -e "Make sure the Disk is not mounted to any imprortant partion and it has data in it: Fpr example :/home /back etc. Please check the partion is empty"
echo -e "\n"
echo -e "Press "$red yes $reset" if you need to unmount the $disk"
read -e yes;
if [ $yes == yes ]
then
echo -e "unmounting the $disk"
umount $disk
cp -pr /etc/fstab /etc/fstab.$(date +%F_%R)
cblkid=`blkid | grep $disk | cut -d '"' -f 2`
sed -i 's/UUID='$cblkid'/#UUID='$cblkid'/g' /etc/fstab
echo -e "\n"
echo -e "Checking the fstab using mount -a"
mount -a
sleep 4
echo -e "Now the Disk is unmounted. Please start the script again and continue with mounting process" 
else 
echo -e "Exit the script"
exit 1
fi
fi
else
echo -e "$red Exiting the Scipt $reset"
fi
