#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom
. /opt/farm/scripts/functions.install


/opt/farm/ext/repos/install.sh security


if [ "$OSTYPE" != "debian" ]; then
	echo "skipping security improvements, unsupported system"
	exit 0
fi

domain=`external_domain`
templates=/opt/farm/ext/secure-system/templates

if [ -f /etc/default/debsums ]; then
	echo "setting up debsums configuration"
	install_copy $templates/default-debsums.tpl /etc/default/debsums

	if [ ! -s /etc/debsums-ignore ]; then
		echo "/usr/share/locale/pl/LC_MESSAGES/mc.mo" >>/etc/debsums-ignore
	fi
fi

if [ -f /etc/default/rkhunter ]; then
	echo "setting up rkhunter configuration"
	cat $templates/default-rkhunter.tpl |sed s/%%domain%%/$domain/g >/etc/default/rkhunter

	if [ -f /etc/systemd/journald.conf ]; then
		syslogcf="/etc/rsyslog.conf /etc/systemd/journald.conf"
	else
		syslogcf="/etc/rsyslog.conf"
	fi

	echo "# This configuration file is maintained by Server Farmer.

MAIL-ON-WARNING=rkhunter@$domain
COPY_LOG_ON_ERROR=1
ALLOW_SSH_ROOT_USER=without-password
ALLOW_SSH_PROT_V1=0
DISABLE_TESTS=deleted_files packet_cap_apps
ALLOW_SYSLOG_REMOTE_LOGGING=1
SYSLOG_CONFIG_FILE=$syslogcf
" >/etc/rkhunter.conf.local
fi


if [ "$HWTYPE" != "container" ] && [ "$HWTYPE" != "lxc" ] && [ ! -d /usr/local/cpanel ] && [ -f /etc/rc.local ] && [ "`grep /proc /etc/rc.local |grep remount`" = "" ]; then
	gid="`getent group newrelic |cut -d: -f3`"
	echo "############################################################################"
	echo "# add the following line to /etc/rc.local file:                            #"
	echo "# mount -o remount,rw,nosuid,nodev,noexec,relatime,hidepid=2,gid=$gid /proc #"
	echo "############################################################################"
fi
