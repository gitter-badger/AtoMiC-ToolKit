#!/bin/bash
# Script Name: AtoMiC HTPC Manager Installer
# Author: htpcBeginner
# Publisher: http://www.htpcBeginner.com
# License: MIT License (refer to README.md for more details)
#

# DO NOT EDIT ANYTHING UNLESS YOU KNOW WHAT YOU ARE DOING.

if [[ $1 != *"setup.sh"* ]]
then
  echo
  echo -e '\e[91mCannot be run directly. Please run setup.sh from AtoMiC ToolKit root folder: \033[0msudo bash setup.sh'
  echo
  exit 0
fi

source $2/inc/commons.sh
source $SCRIPTPATH/inc/header.sh

echo -e $GREEN'AtoMiC HTPC Manager Installer Script'$ENDCOLOR

source $SCRIPTPATH/inc/pause.sh
source $SCRIPTPATH/inc/pkgupdate.sh

echo
sleep 1

echo -e $YELLOW'--->Installing prerequisites...'$ENDCOLOR
sudo apt-get -y install build-essential git python-imaging python-dev python-setuptools python-pip python-cherrypy vnstat 
sudo pip install psutil

echo
sleep 1

echo -e $YELLOW'--->Checking for previous versions of HTPC Manager...'$ENDCOLOR
sleep 1
sudo /etc/init.d/htpcmanager stop >/dev/null 2>&1
echo -e 'Any running HTPC Manager processes stopped'
sleep 1
sudo update-rc.d -f htpcmanager remove >/dev/null 2>&1
sudo rm /etc/init.d/htpcmanager >/dev/null 2>&1
sudo rm /etc/default/htpcmanager >/dev/null 2>&1
echo -e 'Any existing HTPC Manager init scripts removed'
sleep 1
sudo update-rc.d -f htpcmanager remove >/dev/null 2>&1
if [ -d "/home/$UNAME/.htpcmanager" ]; then
	mv /home/$UNAME/.htpcmanager /home/$UNAME/.htpcmanager_`date '+%m-%d-%Y_%H-%M'` >/dev/null 2>&1
	echo -e 'Existing HTPC Manager files were moved to '$CYAN'/home/'$UNAME'/.htpcmanager_'`date '+%m-%d-%Y_%H-%M'`$ENDCOLOR
else
	echo -e 'No previous HTPC Manager folder found'
fi

echo
sleep 1

echo -e $YELLOW'--->Downloading latest HTPC Manager...'$ENDCOLOR
cd /home/$UNAME
git clone https://github.com/styxit/HTPC-Manager.git /home/$UNAME/.htpcmanager || { echo -e $RED'Git not found.'$ENDCOLOR ; exit 1; }
sudo chown -R $UNAME:$UGROUP /home/$UNAME/.htpcmanager >/dev/null 2>&1
sudo chmod 775 -R /home/$UNAME/.htpcmanager >/dev/null 2>&1

echo
sleep 1

echo -e $YELLOW'--->Copying init and config file...'$ENDCOLOR
sudo cp $SCRIPTPATH/htpcmanager/htpcmanager-init /etc/init.d/htpcmanager || { echo -e $RED'Init file not copied.'$ENDCOLOR ; exit 1; }

echo 
sleep 1

echo -e $YELLOW"--->Making some configuration changes..."$ENDCOLOR
sudo sed -i 's/MyUserName/'$UNAME'/g' /etc/init.d/htpcmanager || { echo -e $RED'Replacing username in default failed.'$ENDCOLOR ; exit 1; }

echo 
sleep 1

echo -e $YELLOW'--->Enabling HTPC Manager AutoStart at Boot...'$ENDCOLOR
sudo chown $UNAME:$UGROUP /etc/init.d/htpcmanager
sudo chmod +x /etc/init.d/htpcmanager
sudo update-rc.d htpcmanager defaults

echo
sleep 1

echo -e $YELLOW'--->Stashing any changes made to HTPC Manager...'$ENDCOLOR
cd /home/$UNAME/.htpcmanager
source $SCRIPTPATH/inc/gitstash.sh

echo
sleep 1

echo -e $YELLOW'--->Starting HTPC Manager'$ENDCOLOR
sudo /etc/init.d/htpcmanager start >/dev/null 2>&1

echo
echo -e $GREEN'--->All done. '$ENDCOLOR
echo -e 'HTPC Manager should start within 10-20 seconds and your browser should open.'
echo -e 'If not you can start it using '$CYAN'/etc/init.d/htpcmanager start'$ENDCOLOR' command.'
echo -e 'Then open '$CYAN'http://localhost:8085'$ENDCOLOR' in your browser.'

source $SCRIPTPATH/inc/thankyou.sh
source $SCRIPTPATH/inc/exit.sh