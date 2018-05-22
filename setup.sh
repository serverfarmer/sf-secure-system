#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom
. /opt/farm/scripts/functions.install


/opt/farm/ext/repos/install.sh security


if [ "$OSTYPE" != "debian" ]; then
	echo "skipping security improvements, unsupported system"
	exit 0
fi

templates=/opt/farm/ext/secure-system/templates

if [ -f /etc/default/debsums ]; then
	echo "setting up debsums configuration"
	install_copy $templates/default-debsums.tpl /etc/default/debsums

	if [ ! -s /etc/debsums-ignore ]; then
		echo "/usr/share/locale/pl/LC_MESSAGES/mc.mo" >>/etc/debsums-ignore
	fi
fi

if [ -f /etc/default/rkhunter ]; then
	domain=`external_domain`

	echo "setting up rkhunter configuration"
	cat $templates/default-rkhunter.tpl |sed s/%%domain%%/$domain/g >/etc/default/rkhunter
	/opt/farm/ext/secure-system/config-rkhunter.sh >/etc/rkhunter.conf.local

	save_original_config /etc/rkhunter.conf
	sed -i -e "/^DISABLE_TESTS/d" /etc/rkhunter.conf

	if [ ! -x /usr/bin/lwp-request ]; then
		sed -i -e "/^SCRIPTWHITELIST=\/usr\/bin\/lwp-request/d" /etc/rkhunter.conf
	fi
fi


if [ "$HWTYPE" != "container" ] && [ "$HWTYPE" != "lxc" ] && [ ! -d /usr/local/cpanel ] && [ -f /etc/rc.local ] && [ "`grep /proc /etc/rc.local |grep remount`" = "" ]; then
	gid="`getent group newrelic |cut -d: -f3`"
	echo "############################################################################"
	echo "# add the following line to /etc/rc.local file:                            #"
	echo "# mount -o remount,rw,nosuid,nodev,noexec,relatime,hidepid=2,gid=$gid /proc #"
	echo "############################################################################"
fi
