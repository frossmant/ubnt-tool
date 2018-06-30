#!/bin/bash

VERSION_INSTALLED=`cat /opt/UniFi/data/db/version`
VERSION_LATEST=`curl --silent https://help.ubnt.com/hc/en-us/articles/115000441548-UniFi-Current-Controller-Versions|grep -w Stable|grep -v Candidate|grep -v LTS|grep http|sed 's/<[^>]\+>//g'`

function clean()
{
	[ -e file ] && rm /tmp/unifi.zip 
}
function unifi_backup()
{
	systemctl stop unifi
	tar -zcvf /shared/backup/sth-ka-net000.cinqore.se/unifi_controller.tar.gz /opt/UniFi/data/
	systemctl start unifi
}
function unifi_download()
{
	VERSION=$1
	wget -q https://dl.ubnt.com/unifi/${VERSION}/UniFi.unix.zip -O /tmp/unifi.zip 
}
function unifi_upgrade()
{
	systemctl stop unifi
	unzip -qq -o /tmp/unifi.zip -d /opt
	chown -R ubnt:ubnt /opt/UniFi
	# OpenSuSE Leap fix for broken mongodb symlink
	ln -sf /usr/sbin/mongod /opt/UniFi/bin/mongod
	systemctl start unifi
}

if [ ${VERSION_INSTALLED} = ${VERSION_LATEST} ]
then
	echo "latest version already installed, exiting script"
	exit 0
fi

clean
echo "Downloading version ${VERSION_LATEST} (installed version is ${VERSION_INSTALLED}"
unifi_download ${VERSION_LATEST}
echo "Stopping UniFi Controller and upgrading software"
unifi_upgrade
echo "cleaning temporary upgrade files"
clean
exit 0
