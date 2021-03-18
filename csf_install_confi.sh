#/bin/bash
###################################
# Created by MelvinTazz           #
# Email Id : melvintazz@gmail.com #
###################################
echo -e "*****  Installing and configuring the complete CSF with differnt rules  ****"
echo -e "Do you need to install CSF or to just Add Rules in CSF. Please select the below options"
echo -e "Press 1 to Install CSF and then Add Rules in CSF"
echo -e "Press 2 to Add Rules in CSF(For those who installed CSF already)"
echo -e "Press 3 to uninstall CSF from the server"
read miz
case "$miz" in
"1")
cd /usr/src
rm -fv csf.tgz
wget https://download.configserver.com/csf.tgz
tar -xzf csf.tgz
cd csf
sh install.sh
echo -e "installation completed : now restarting CSF"
csf -r
echo -e "Now you are good to go"
echo "Do you want to setup rules (yes/no)"
read giz
if [ $giz = yes ]
then
echo -e Below mentioned are the rules details::
echo -e "#############################################################################################################################"
echo -e "# Strict:                               #     Hard:                                 #      Simple:                          #"
echo -e "# CT_LIMIT = 20                         #  CT_LIMIT =  30                           # CT_LIMIT =  40                        #"
echo -e "# CT_PORTS = 80,443,22,21               #  CT_PORTS = 80,443                        # CT_PORTS = 80,443                     #"
echo -e "# SYNFLOOD =  1                         #  SYNFLOOD =  0                            # SYNFLOOD =  0                         #"
echo -e "# SMTP_ALLOWLOCAL =  1                  #  SMTP_ALLOWLOCAL =  1                     # SMTP_ALLOWLOCAL =  1                  #"
echo -e "# SYNFLOOD_RATE =  20/s                 #  SYNFLOOD_RATE = 40/s                     # SYNFLOOD_RATE =  100/s                #"
echo -e "# SYNFLOOD_BURST =  5                   #  SYNFLOOD_BURST =  10                     # SYNFLOOD_BURST =  15                  #"
echo -e "# LF_DISTATTACK =  1                    #  N/A                                      # N/A                                   #"
echo -e "# SAFECHAINUPDATE =  0                  #  N/A                                      # N/A                                   #"
echo -e "# CONNLIMIT =  22;5,80;20               #  CONNLIMIT =  22;5,80;50                  # CONNLIMIT =  22;5,80;20               #"                 
echo -e "# PORTFLOOD =  22;tcp;5;300,80;tcp;20;5 #  PORTFLOOD =  22;tcp;5;300,80;tcp;50;5    # PORTFLOOD =  22;tcp;5;300,80;tcp;90;5 #"
echo -e "# CSF Honeypot- Block List              #  N/A                                      # N/A                                   #"
echo -e "#############################################################################################################################"
echo -e "# Strict should be only enabled if you are in an attack :::::::DDOS,SYN etc::::::::                                         #"
echo -e "# Hard and simple can be enabled based on the Needs and attack level                                                        #"
echo -e "# CSF IP Block Lists:This feature allows csf to periodically download lists of IP addresses and CIDRs from published block  #"
echo -e "#############################################################################################################################"
echo -e "How would you like to configure the csf. Please choose any one of the options"
echo -e "Press 1 for Strict rules"
echo -e "Press 2 for Hard rules"
echo -e "Press 3 for simple rules"
read tiz
        case "$tiz" in
        "1")
        echo Setting Strict Rule ........
        grep -rl 'TESTING = ".*"' /etc/csf/csf.conf | xargs sed -i 's/TESTING = ".*"/TESTING = "0"/g'
        grep -rl 'CT_LIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_LIMIT = ".*"/CT_LIMIT = "20"/g'
        grep -rl 'CT_PORTS = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_PORTS = ".*"/CT_PORTS = "80,443,22,21"/g'
        grep -rl 'SYNFLOOD = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD = ".*"/SYNFLOOD = "1"/g'
        grep -rl 'SYNFLOOD_RATE = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_RATE = ".*"/SYNFLOOD_RATE = "20"/g'
        grep -rl 'SYNFLOOD_BURST = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_BURST = ".*"/SYNFLOOD_BURST = "5"/g'
        grep -rl 'LF_DISTATTACK = ".*"' /etc/csf/csf.conf  | xargs sed -i 's/LF_DISTATTACK = ".*"/LF_DISTATTACK = "1"/g'
        grep -rl 'CONNLIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CONNLIMIT = ".*"/CONNLIMIT = "22;5,80;20"/g'
        grep -rl 'PORTFLOOD = ".*"' /etc/csf/csf.conf | xargs sed -i 's/PORTFLOOD = ".*."/PORTFLOOD = "22;tcp;5;300,80;tcp;20;5"/g'
        echo "SPAMDROP|86400|0|http://www.spamhaus.org/drop/drop.lasso" >> /etc/csf/csf.blocklists
        echo "SPAMEDROP|86400|0|http://www.spamhaus.org/drop/edrop.lasso" >> /etc/csf/csf.blocklists
        echo "DSHIELD|86400|0|http://www.dshield.org/block.txt" >> /etc/csf/csf.blocklists
        echo "TOR|86400|0|https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.2.3.4" >> /etc/csf/csf.blocklists
        echo "ALTTOR|86400|0|http://torstatus.blutmagie.de/ip_list_exit.php/Tor_ip_list_EXIT.csv" >> /etc/csf/csf.blocklists
        echo "BOGON|86400|0|http://www.cymru.com/Documents/bogon-bn-agg.txt" >> /etc/csf/csf.blocklists
        echo "HONEYPOT|86400|0|http://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1" >> /etc/csf/csf.blocklists
        echo "HONEYPOT|86400|0|http://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1" >> /etc/csf/csf.blocklists
        echo "CIARMY|86400|0|http://www.ciarmy.com/list/ci-badguys.txt" >> /etc/csf/csf.blocklists
        echo "BFB|86400|0|http://danger.rulez.sk/projects/bruteforceblocker/blist.php" >> /etc/csf/csf.blocklists
        echo "OPENBL|86400|0|https://www.openbl.org/lists/base_30days.txt" >> /etc/csf/csf.blocklists
        echo "MAXMIND|86400|0|https://www.maxmind.com/en/anonymous_proxies" >> /etc/csf/csf.blocklists
        echo "BDE|3600|0|https://api.blocklist.de/getlast.php?time=3600" >> /etc/csf/csf.blocklists
        echo "BDEALL|86400|0|http://lists.blocklist.de/lists/all.txt" >> /etc/csf/csf.blocklists
        echo "STOPFORUMSPAM|86400|0|http://www.stopforumspam.com/downloads/listed_ip_1.zip" >> /etc/csf/csf.blocklists
        echo "GREENSNOW|86400|0|http://blocklist.greensnow.co/greensnow.txt" >> /etc/csf/csf.blocklists
        echo ">>>>>>Restarting the CSF <<<<<<<<<<<<<<<<<<"
        csf -r
        echo All done.. Good to go
        ;;
"2")
        echo Setting Hard Rule
        grep -rl 'TESTING = ".*"' /etc/csf/csf.conf | xargs sed -i 's/TESTING = ".*"/TESTING = "0"/g'
        grep -rl 'CT_LIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_LIMIT = ".*"/CT_LIMIT = "30"/g'
        grep -rl 'CT_PORTS = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_PORTS = ".*"/CT_PORTS = "80,443"/g'
        grep -rl 'SYNFLOOD_RATE = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_RATE = ".*"/SYNFLOOD_RATE = "40"/g'
        grep -rl 'SYNFLOOD_BURST = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_BURST = ".*"/SYNFLOOD_BURST = "10"/g'
        grep -rl 'CONNLIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CONNLIMIT = ".*"/CONNLIMIT = "22;5,80;20"/g'
        grep -rl 'PORTFLOOD = ".*"' /etc/csf/csf.conf | xargs sed -i 's/PORTFLOOD = ".*."/PORTFLOOD = "22;tcp;5;300,80;tcp;50;5"/g'
        echo ">>>>>>>>>>>>>>>>>>Restarting the CSF<<<<<<<<<<<<<<<<"
        csf -r
        echo Hard Rule setting completed. You are good to go:
        ;;
        "3")
        echo Setting Simple Rules
        grep -rl 'TESTING = ".*"' /etc/csf/csf.conf | xargs sed -i 's/TESTING = ".*"/TESTING = "0"/g'
        grep -rl 'CT_LIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_LIMIT = ".*"/CT_LIMIT = "40"/g'
        grep -rl 'CT_PORTS = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_PORTS = ".*"/CT_PORTS = "80,443"/g'
        grep -rl 'SYNFLOOD_RATE = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_RATE = ".*"/SYNFLOOD_RATE = "100"/g'
        grep -rl 'SYNFLOOD_BURST = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_BURST = ".*"/SYNFLOOD_BURST = "15"/g'
        grep -rl 'CONNLIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CONNLIMIT = ".*"/CONNLIMIT = "22;5,80;20"/g'
        grep -rl 'PORTFLOOD = ".*"' /etc/csf/csf.conf | xargs sed -i 's/PORTFLOOD = ".*."/PORTFLOOD = "22;tcp;5;300,80;tcp;90;5"/g'
        echo ">>>>>>>>>>>>>>>>>>Restarting the CSF<<<<<<<<<<<<<<<<"
        csf -r
        echo Simple Rule setting completed. You are good to go:
        ;;
        esac
fi
#echo check
;;
"2")
echo -e Below mentioned are the rules details::
echo -e "#############################################################################################################################"
echo -e "# Strict:                               #     Hard:                                 #      Simple:                          #"
echo -e "# CT_LIMIT = 20                         #  CT_LIMIT =  30                           # CT_LIMIT =  40                        #"
echo -e "# CT_PORTS = 80,443,22,21               #  CT_PORTS = 80,443                        # CT_PORTS = 80,443                     #"
echo -e "# SYNFLOOD =  1                         #  SYNFLOOD =  0                            # SYNFLOOD =  0                         #"
echo -e "# SMTP_ALLOWLOCAL =  1                  #  SMTP_ALLOWLOCAL =  1                     # SMTP_ALLOWLOCAL =  1                  #"
echo -e "# SYNFLOOD_RATE =  20/s                 #  SYNFLOOD_RATE = 40/s                     # SYNFLOOD_RATE =  100/s                #"
echo -e "# SYNFLOOD_BURST =  5                   #  SYNFLOOD_BURST =  10                     # SYNFLOOD_BURST =  15                  #"
echo -e "# LF_DISTATTACK =  1                    #  N/A                                      # N/A                                   #"
echo -e "# SAFECHAINUPDATE =  0                  #  N/A                                      # N/A                                   #"
echo -e "# CONNLIMIT =  22;5,80;20               #  CONNLIMIT =  22;5,80;50                  # CONNLIMIT =  22;5,80;20               #"                 
echo -e "# PORTFLOOD =  22;tcp;5;300,80;tcp;20;5 #  PORTFLOOD =  22;tcp;5;300,80;tcp;50;5    # PORTFLOOD =  22;tcp;5;300,80;tcp;90;5 #"
echo -e "# CSF Honeypot- Block List              #  N/A                                      # N/A                                   #"
echo -e "#############################################################################################################################"
echo -e "# Strict should be only enabled if you are in an attack :::::::DDOS,SYN etc::::::::                                         #"
echo -e "# Hard and simple can be enabled based on the Needs and attack level                                                        #"
echo -e "# CSF IP Block Lists:This feature allows csf to periodically download lists of IP addresses and CIDRs from published block  #"
echo -e "#############################################################################################################################"
echo -e "How would you like to configure the csf. Please choose any one of the options"
echo -e "Press 1 for Strict rules"
echo -e "Press 2 for Hard rules"
echo -e "Press 3 for simple rules"
read tiz
case "$tiz" in
"1")
echo Setting Strict Rule ........
grep -rl 'TESTING = ".*"' /etc/csf/csf.conf | xargs sed -i 's/TESTING = ".*"/TESTING = "0"/g'
grep -rl 'CT_LIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_LIMIT = ".*"/CT_LIMIT = "20"/g'
grep -rl 'CT_PORTS = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_PORTS = ".*"/CT_PORTS = "80,443,22,21"/g'
grep -rl 'SYNFLOOD = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD = ".*"/SYNFLOOD = "1"/g'
grep -rl 'SYNFLOOD_RATE = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_RATE = ".*"/SYNFLOOD_RATE = "20"/g'
grep -rl 'SYNFLOOD_BURST = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_BURST = ".*"/SYNFLOOD_BURST = "5"/g'
grep -rl 'LF_DISTATTACK = ".*"' /etc/csf/csf.conf  | xargs sed -i 's/LF_DISTATTACK = ".*"/LF_DISTATTACK = "1"/g'
grep -rl 'CONNLIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CONNLIMIT = ".*"/CONNLIMIT = "22;5,80;20"/g'
grep -rl 'PORTFLOOD = ".*"' /etc/csf/csf.conf | xargs sed -i 's/PORTFLOOD = ".*."/PORTFLOOD = "22;tcp;5;300,80;tcp;20;5"/g'
echo "SPAMDROP|86400|0|http://www.spamhaus.org/drop/drop.lasso" >> /etc/csf/csf.blocklists
echo "SPAMEDROP|86400|0|http://www.spamhaus.org/drop/edrop.lasso" >> /etc/csf/csf.blocklists
echo "DSHIELD|86400|0|http://www.dshield.org/block.txt" >> /etc/csf/csf.blocklists
echo "TOR|86400|0|https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.2.3.4" >> /etc/csf/csf.blocklists
echo "ALTTOR|86400|0|http://torstatus.blutmagie.de/ip_list_exit.php/Tor_ip_list_EXIT.csv" >> /etc/csf/csf.blocklists
echo "BOGON|86400|0|http://www.cymru.com/Documents/bogon-bn-agg.txt" >> /etc/csf/csf.blocklists
echo "HONEYPOT|86400|0|http://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1" >> /etc/csf/csf.blocklists
echo "HONEYPOT|86400|0|http://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1" >> /etc/csf/csf.blocklists
echo "CIARMY|86400|0|http://www.ciarmy.com/list/ci-badguys.txt" >> /etc/csf/csf.blocklists
echo "BFB|86400|0|http://danger.rulez.sk/projects/bruteforceblocker/blist.php" >> /etc/csf/csf.blocklists
echo "OPENBL|86400|0|https://www.openbl.org/lists/base_30days.txt" >> /etc/csf/csf.blocklists
echo "MAXMIND|86400|0|https://www.maxmind.com/en/anonymous_proxies" >> /etc/csf/csf.blocklists
echo "BDE|3600|0|https://api.blocklist.de/getlast.php?time=3600" >> /etc/csf/csf.blocklists
echo "BDEALL|86400|0|http://lists.blocklist.de/lists/all.txt" >> /etc/csf/csf.blocklists
echo "STOPFORUMSPAM|86400|0|http://www.stopforumspam.com/downloads/listed_ip_1.zip" >> /etc/csf/csf.blocklists
echo "GREENSNOW|86400|0|http://blocklist.greensnow.co/greensnow.txt" >> /etc/csf/csf.blocklists
echo ">>>>>>Restarting the CSF <<<<<<<<<<<<<<<<<<"
csf -r
echo All done.. Good to go
;;
"2")
echo Setting Hard Rule
grep -rl 'TESTING = ".*"' /etc/csf/csf.conf | xargs sed -i 's/TESTING = ".*"/TESTING = "0"/g'
grep -rl 'CT_LIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_LIMIT = ".*"/CT_LIMIT = "30"/g'
grep -rl 'CT_PORTS = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_PORTS = ".*"/CT_PORTS = "80,443"/g'
grep -rl 'SYNFLOOD_RATE = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_RATE = ".*"/SYNFLOOD_RATE = "40"/g'
grep -rl 'SYNFLOOD_BURST = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_BURST = ".*"/SYNFLOOD_BURST = "10"/g'
grep -rl 'CONNLIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CONNLIMIT = ".*"/CONNLIMIT = "22;5,80;20"/g'
grep -rl 'PORTFLOOD = ".*"' /etc/csf/csf.conf | xargs sed -i 's/PORTFLOOD = ".*."/PORTFLOOD = "22;tcp;5;300,80;tcp;50;5"/g'
echo ">>>>>>>>>>>>>>>>>>Restarting the CSF<<<<<<<<<<<<<<<<"
csf -r
echo Hard Rule setting completed. You are good to go:
;;
"3")
echo Setting Simple Rules
grep -rl 'TESTING = ".*"' /etc/csf/csf.conf | xargs sed -i 's/TESTING = ".*"/TESTING = "0"/g'
grep -rl 'CT_LIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_LIMIT = ".*"/CT_LIMIT = "40"/g'
grep -rl 'CT_PORTS = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CT_PORTS = ".*"/CT_PORTS = "80,443"/g'
grep -rl 'SYNFLOOD_RATE = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_RATE = ".*"/SYNFLOOD_RATE = "100"/g'
grep -rl 'SYNFLOOD_BURST = ".*"' /etc/csf/csf.conf | xargs sed -i 's/SYNFLOOD_BURST = ".*"/SYNFLOOD_BURST = "15"/g'
grep -rl 'CONNLIMIT = ".*"' /etc/csf/csf.conf | xargs sed -i 's/CONNLIMIT = ".*"/CONNLIMIT = "22;5,80;20"/g'
grep -rl 'PORTFLOOD = ".*"' /etc/csf/csf.conf | xargs sed -i 's/PORTFLOOD = ".*."/PORTFLOOD = "22;tcp;5;300,80;tcp;90;5"/g'
echo ">>>>>>>>>>>>>>>>>>Restarting the CSF<<<<<<<<<<<<<<<<"
        csf -r
        echo Simple Rule setting completed. You are good to go:
;;
esac
;;
"3")
echo -e uninstalling the csf. Please wait:::
/usr/src/csf/uninstall.sh
echo -e Uninstallation completed::
;;
esac
