#!/bin/sh
. /opt/farm/scripts/init


disabletests="deleted_files packet_cap_apps suspscan"

if [ "$HWTYPE" = "container" ] || [ "$HWTYPE" = "lxc" ]; then
	disabletests="$disabletests hidden_procs os_specific"
fi

if ! grep -qFx $OSVER /opt/farm/ext/secure-system/config/apps.conf; then
	disabletests="$disabletests apps"
fi

if [ -f /etc/systemd/journald.conf ]; then
	syslogcf="/etc/rsyslog.conf /etc/systemd/journald.conf"
else
	syslogcf="/etc/rsyslog.conf"
fi

echo "# This configuration file is maintained by Server Farmer.

ALLOW_SSH_ROOT_USER=without-password
ALLOW_SSH_PROT_V1=0

ALLOW_SYSLOG_REMOTE_LOGGING=1
SYSLOG_CONFIG_FILE=$syslogcf

COPY_LOG_ON_ERROR=1
DISABLE_TESTS=$disabletests

ALLOWHIDDENDIR=/etc/.java
ALLOWHIDDENDIR=/dev/.udev
ALLOWHIDDENFILE=/dev/.blkid.tab
ALLOWHIDDENFILE=/dev/.blkid.tab.old
ALLOWHIDDENFILE=/dev/.initramfs
ALLOWDEVFILE=/dev/.udev/rules.d/root.rules
ALLOWDEVFILE=/dev/shm/PostgreSQL.*
ALLOWDEVFILE=/dev/shm/spice.*
"

if [ -f /etc/X11/xinit/xinitrc ]; then
	echo "ALLOWDEVFILE=/dev/shm/mono.*"
fi

if [ -x /usr/bin/lwp-request ]; then
	echo "SCRIPTWHITELIST=/usr/bin/lwp-request"
fi

if [ -f /usr/bin/unhide.rb ]; then
	echo "SCRIPTWHITELIST=/usr/bin/unhide.rb"
fi

if [ -f /usr/lib/arm-linux-gnueabihf/libarmmem.so ]; then
	echo "SHARED_LIB_WHITELIST=/usr/lib/arm-linux-gnueabihf/libarmmem.so"
fi

if [ -x /usr/bin/curl ]; then
	echo "WEB_CMD=/usr/bin/curl"
elif [ -x /usr/bin/wget ]; then
	echo "WEB_CMD=/usr/bin/wget"
else
	echo "WEB_CMD=/bin/false"
fi
