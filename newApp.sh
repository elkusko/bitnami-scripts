#!/bin/sh

# Allow only root execution
if [ `id|sed -e s/uid=//g -e s/\(.*//g` -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi


# Disabling SELinux if enabled
if [ -f "/usr/sbin/getenforce" ] && [ `id -u` = 0 ] ; then
    selinux_status=`/usr/sbin/getenforce`
    /usr/sbin/setenforce 0 2> /dev/null
fi

if [ -z "$1" ];then
echo "need app to create"
exit 1
fi
NEWAPP="$1"

#base AIM path
INSTALLDIR=/opt/bitnami

#Apache app prefix to be updated later
APACHEAPPSPREFIX=$INSTALLDIR/apache2/conf/bitnami/bitnami-apps-prefix.conf

APPDIR=$INSTALLDIR/apps/$NEWAPP
# Control app dirs.
if [ -d "$APPDIR" ]; then
echo "$APPDIR already exists"
exit 1
fi

echo "Making App Folders"

mkdir -p $APPDIR

APPHTDOCSDIR=$APPDIR/htdocs
mkdir -p $APPHTDOCSDIR

APPCONFDIR=$APPDIR/conf
mkdir -p $APPCONFDIR

APPDATADIR=$APPDIR/data
mkdir -p $APPDATADIR

HTTPDPREFIX=$APPCONFDIR/httpd-prefix.conf
HTTPDAPP=$APPCONFDIR/httpd-app.conf

echo "Writing: $HTTPDPREFIX"

cat > $HTTPDPREFIX <<EOL
Alias /${NEWAPP}/ "${APPHTDOCSDIR}/"
Alias /${NEWAPP} "${APPHTDOCSDIR}"
Include "${HTTPDAPP}"
EOL

echo "Writing: $HTTPDAPP"

cat > $HTTPDAPP <<EOL
<Directory ${APPHTDOCSDIR}>
    Options +FollowSymLinks
    AllowOverride None
    <IfVersion < 2.3 >
    Order allow,deny
    Allow from all
    </IfVersion>
    <IfVersion >= 2.3>
    Require all granted
    </IfVersion>
</Directory>
EOL

echo "Appending: $APACHEAPPSPREFIX"

cat >> $APACHEAPPSPREFIX <<EOL
Include "${HTTPDPREFIX}"
EOL

echo "Adding index.php"

cat > $APPHTDOCSDIR/index.php <<EOL
<html>
<body>
<h1>${NEWAPP} is ready to go!!</h1>
<p>Hope this little script relieved you.</p>
<p>Regards,<br><a href="https://github.com/elkusko">Rolando Lucio</a></p>
<a href="https://github.com/elkusko/bitnami-scripts"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://camo.githubusercontent.com/38ef81f8aca64bb9a64448d0d70f1308ef5341ab/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png"></a>
</body
</html>
EOL

echo "Changing ownership $APPHTDOCSDIR"
chown -R bitnami:daemon $APPHTDOCSDIR

echo "Updating permissions $APPHTDOCSDIR"
find $APPHTDOCSDIR/ -type f -exec chmod 664 {} \;
find $APPHTDOCSDIR/ -type d -exec chmod 755 {} \;


echo "Restart Apache"
$INSTALLDIR/ctlscript.sh restart apache


echo "Custom PHP Application Added: $NEWAPP"
