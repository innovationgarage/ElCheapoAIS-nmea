#! /bin/bash

argparse() {
   export ARGS=()
   for _ARG in "$@"; do
       if [ "${_ARG##--*}" == "" ]; then
           _ARG="${_ARG#--}"
           if [ "${_ARG%%*=*}" == "" ]; then
               _ARGNAME="$(echo ${_ARG%=*} | tr -_ )"
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
EOF
    exit 1
fi


# General dependencies
echo Installing dependencies

apt install -y python3 python3-pip python3-setuptools python3-dev git gcc openssh-server openssh-client bash

mkdir -p /var/log/elcheapoais
mkdir -p /usr/local/bin
mkdir -p /lib/elcheapoais

cp -r ./etc /etc/elcheapoais

# setuptools fails to install these properly as dependencies, so install them manually
python3 -m pip install click-datetime
python3 -m pip install dbus-python
python3 -m pip install PyGObject

components=config parser downsampler TUI

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
    cp elcheapoais-${component}.sh /usr/local/bin/elcheapoais-${component}.sh
    chmod a+x /usr/local/bin/elcheapoais-${component}.sh
    cp elcheapoais-${component}.service /lib/systemd/system/elcheapoais-${component}.service
done

mkdir -p /etc/systemd/system/serial-getty@.service.d
cp elcheapoais-tui.service-config /etc/systemd/system/serial-getty@.service.d/20-autologin.conf

systemctl daemon-reload

for component in ${components}; do
    systemctl enable elcheapoais-${component}.service
done

(
	echo "Installing manhole..."
        cd /tmp
        git clone --branch $ARG_branch https://github.com/innovationgarage/ElCheapoAIS-manhole.git
        cd ElCheapoAIS-manhole

        cp manhole.sh elcheapoais-manhole-signal-status.py /usr/local/bin/manhole.sh
        chmod ugo+x /usr/local/bin/manhole.sh /usr/local/bin/elcheapoais-manhole-signal-status.py

        cp crontab /etc/cron.d/manhole
)



# Some generic system config
# - Forbid password login over ssh

sed -i -e "s+#\? *PasswordAuthentication *yes+PasswordAuthentication no+g" /etc/ssh/sshd_config
