#!/bin/bash
# shellcheck disable=SC1090
echo
echo -e "${YELLOW}--->configuring NGIX for $APPTITLE...$ENDCOLOR"
if [[ -d $APPPATH ]]; then

    # Stop Nginx
    APPNAMETEMP=$APPNAME
    APPNAME='nginx'
    source "$SCRIPTPATH/inc/app-stop.sh"
    APPNAME=$APPNAMETEMP

    sudo chown -R www-data:www-data "$APPPATH"
    echo "Set the correct folder permissions"

    cp "$SCRIPTPATH/$APPNAME/$APPNAME-nginx" \
        "/etc/nginx/sites-available/$APPNAME" || \
        { echo "${RED}Could not move $APPSETTINGS file.$ENDCOLOR" ; exit 1; }
    echo "Copied config file over"

    sudo sed -i "s@FPMVERSION@$FPMVERSION@g" \
            "/etc/nginx/sites-available/$APPNAME" || \
            { echo -e "${RED}Modifying FPMVERSION in Nginx file failed.$ENDCOLOR"; exit 1; }
    echo "Updated config file with correct PHP Version"

    sudo sed -i "s@IPADDRESS@$(hostname -I)@g" \
            "/etc/nginx/sites-available/$APPNAME" || \
            { echo -e "${RED}Modifying IPADDRESS in Nginx file failed.$ENDCOLOR"; exit 1; }
    echo "Updated config file with current IPAddress"

    if [[ ! -L "/etc/nginx/sites-enabled/$APPNAME" ]]; then
        sudo ln -s "/etc/nginx/sites-available/$APPNAME" \
                    "/etc/nginx/sites-enabled/$APPNAME"
        echo "Symlinked the $APPNAME virtual host"
    fi

    # Start Nginx
    APPNAMETEMP=$APPNAME
    APPNAME='nginx'
    source "$SCRIPTPATH/inc/app-start.sh"
    APPNAME=$APPNAMETEMP
else
    echo "No application path found for $APPTITLE"
fi
