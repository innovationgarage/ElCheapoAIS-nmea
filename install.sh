#! /bin/bash

argparse() {
   export ARGS=()
   for _ARG in "$@"; do
       if [ "${_ARG##--*}" == "" ]; then
           _ARG="${_ARG#--}"
           if [ "${_ARG%%*=*}" == "" ]; then
               _ARGNAME="$(echo ${_ARG%=*} | tr - _ )"
               eval "export ARG_${_ARGNAME}"='"${_ARG#*=}"'
           else
               eval "export ARG_${_ARG}"='True'
           fi
       else
           ARGS+=($_ARG)
       fi
   done
}

ARG_branch="dbus-0.1"

argparse "$@"

if [ "$ARG_help" ]; then
    cat <<EOF
Usage: install.sh OPTIONS
  Where options are any of

    --branch=${ARG_branch}
    --no-readonly
EOF
    exit 1
fi


# General dependencies
echo Installing dependencies

apt update

# Watchdog: https://forum.armbian.com/topic/2898-how-to-install-enable-and-start-watchdog-in-h3/
apt install -y python3
apt install -y python3-pip
apt install -y python3-setuptools
apt install -y python3-dev
apt install -y git
apt install -y gcc
apt install -y openssh-server
apt install -y openssh-client
apt install -y bash
apt install -y libdbus-1-dev
apt install -y libglib2.0-dev
apt install -y libcairo2-dev
apt install -y watchdog
apt install -y overlayroot
apt install -y network-manager

mkdir -p /var/log/elcheapoais
mkdir -p /usr/local/bin
mkdir -p /lib/elcheapoais

cp -r ./etc /etc/elcheapoais

# setuptools fails to install these properly as dependencies, so install them manually
python3 -m pip install click-datetime
python3 -m pip install dbus-python
python3 -m pip install pycairo
python3 -m pip install PyGObject


components="config parser downsampler TUI"

for component in ${components}; do
(
    echo "Installing ${component}..."
    cd /tmp
    git clone --branch $ARG_branch https://github.com/innovationgarage/ElCheapoAIS-${component}.git
    cd ElCheapoAIS-${component}
    python3 setup.py install
)
done

for component in ${components}; do
    echo "Configuring ${component}..."
    cp elcheapoais-${component}.service /lib/systemd/system/elcheapoais-${component}.service
done

mkdir -p /etc/systemd/system/serial-getty@.service.d
cp elcheapoais-tui.service-config /etc/systemd/system/serial-getty@.service.d/20-autologin.conf

cp no.innovationgarage.elcheapoais.conf /etc/dbus-1/system.d/

systemctl daemon-reload

for component in ${components}; do
    systemctl enable elcheapoais-${component}.service
done

(
	echo "Installing manhole..."
        cd /tmp
        git clone --branch $ARG_branch https://github.com/innovationgarage/ElCheapoAIS-manhole.git
        cd ElCheapoAIS-manhole

        cp manhole.sh elcheapoais-manhole-dbus /usr/local/bin
        chmod ugo+x /usr/local/bin/{manhole.sh,elcheapoais-manhole-dbus}

        cp crontab /etc/cron.d/manhole
)



# Some generic system config
# - Forbid password login over ssh

sed -i -e "s+#\? *PasswordAuthentication *yes+PasswordAuthentication no+g" /etc/ssh/sshd_config

# Throttle the CPU so we don't overheat
# Throttling: https://forum.armbian.com/topic/9255-orangepi-pc-cpu-frequency/?tab=comments#comment-69278
# Measure temperature: https://forum.armbian.com/topic/3779-orangepi-zero-high-temperature/
sed -i -e "s+MAX_SPEED=.*+MAX_SPEED=480000+g" /etc/default/cpufrequtils

if [ -e /usr/sbin/netplan ]; then
  cat > /etc/netplan/01-network-manager-all.yaml <<EOF
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
EOF
  netplan generate
  netplan apply
fi

# https://docs.armbian.com/User-Guide_Advanced-Features/#how-to-freeze-your-filesystem
[ "$ARG_no_readonly" ] || echo 'overlayroot="tmpfs"' >> /etc/overlayroot.conf
