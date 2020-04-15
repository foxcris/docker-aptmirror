#!/bin/bash

#mirror.list erstellen

echo set base_path /mnt/aptmirror > /etc/apt/mirror.list
echo set nthreads     20 >> /etc/apt/mirror.list
set _tilde 0 >> /etc/apt/mirror.list

if [ "${APTMIRROR_DEBIAN_STRETCH}" = "true" ]
then
    echo # DEBIAN STRETCH
    echo deb-amd64 http://ftp2.de.debian.org/debian/ stretch main >> /etc/apt/mirror.list
    echo deb-amd64 http://security.debian.org/debian-security stretch/updates main  contrib non-free >> /etc/apt/mirror.list
    echo deb-amd64 http://ftp2.de.debian.org/debian/ stretch-updates main >> /etc/apt/mirror.list
    echo deb-amd64 http://deb.debian.org/debian stretch-backports main >> /etc/apt/mirror.list
    echo # DEBIAN STRETCH END
fi

if [ "${APTMIRROR_DEBIAN_BUSTER}" = "true" ]
then
    echo # DEBIAN BUSTER
    echo deb-amd64 http://ftp2.de.debian.org/debian/ buster main >> /etc/apt/mirror.list
    echo deb-amd64 http://security.debian.org/debian-security buster/updates main  contrib non-free >> /etc/apt/mirror.list
    echo deb-amd64 http://ftp2.de.debian.org/debian/ buster-updates main >> /etc/apt/mirror.list
    echo deb-amd64 http://deb.debian.org/debian buster-backports main >> /etc/apt/mirror.list
    echo # DEBIAN BUSTER END
fi

if [ "${APTMIRROR_UBUNTU_BIONIC}" = "true" ]
then
    echo # UBUNTU BIONIC
    echo deb http://us.archive.ubuntu.com/ubuntu/ bionic main restricted >> /etc/apt/mirror.list
    echo deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted >> /etc/apt/mirror.list
    echo deb http://us.archive.ubuntu.com/ubuntu/ bionic universe >> /etc/apt/mirror.list
    echo deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates universe >> /etc/apt/mirror.list
    echo deb http://us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse >> /etc/apt/mirror.list
    echo deb http://security.ubuntu.com/ubuntu bionic-security main restricted >> /etc/apt/mirror.list
    echo deb http://security.ubuntu.com/ubuntu bionic-security universe >> /etc/apt/mirror.list
    echo deb http://security.ubuntu.com/ubuntu bionic-security multiverse >> /etc/apt/mirror.list
    echo # UBUNTU BIONIC END
fi

if [ "${APTMIRROR_CUSTOMFILE}" != "" ]
then
    cat ${APTMIRROR_CUSTOMFILE} >> /etc/apt/mirror.list
fi

#Create cron entry
if [ "${APTMIRROR_CRON}" != "" ]
then
    crontime="${APTMIRROR_CRON}"
else
    crontime="* */6 * * *"
fi
echo "@reboot apt-mirror rm -r /mnt/apt-mirror/var/apt-mirror.lock; /usr/bin/apt-mirror 2>&1 | logger" > /etc/cron.d/apt-mirror
echo "${crontime} apt-mirror /usr/bin/apt-mirror 2>&1 | logger" >> /etc/cron.d/apt-mirror
chmod 0644 /etc/cron.d/apt-mirror

#setting correct permissions
chown -R apt-mirror:apt-mirror /mnt/aptmirror

/etc/init.d/rsyslog start
/etc/init.d/cron start

while [ ! -f /var/log/syslog ]
do
  sleep 1s
done
tail -f /var/log/syslog
