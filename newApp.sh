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

APPDIR=$INSTALLDIR/apps/$NEWAPP
# Control app dirs.
if [ -d "$APPDIR" ]; then
echo "$APPDIR already exists"
exit 1
fi

echo "Making App Folders"

mkdir -p $APPDIR
mkdir -p $INSTALLDIR/apps/$NEWAPP/htdocs
mkdir -p $INSTALLDIR/apps/$NEWAPP/conf
mkdir -p $INSTALLDIR/apps/$NEWAPP/data

HTTPDPREFIX=$INSTALLDIR/apps/$NEWAPP/conf/httpd-prefix.conf

echo "Writing: $HTTPDPREFIX"

cat > $HTTPDPREFIX <<EOL
Alias /${NEWAPP}/ "${INSTALLDIR}/apps/${NEWAPP}/htdocs/"
Alias /${NEWAPP} "${INSTALLDIR}/apps/${NEWAPP}/htdocs"
Include "${INSTALLDIR}/apps/${NEWAPP}/conf/httpd-app.conf"
EOL


HTTPDAPP=$INSTALLDIR/apps/$NEWAPP/conf/httpd-app.conf

echo "Writing: $HTTPDAPP"

cat > $HTTPDAPP <<EOL
<Directory ${INSTALLDIR}/apps/${NEWAPP}/htdocs>
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
