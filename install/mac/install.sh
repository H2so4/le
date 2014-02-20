#!/usr/bin/env bash

#############################################
#
#       Quickstart Agent Installer
#       Author: Stephen Hynes
#       Version: 1.0
#
#############################################

# Need root to run this script
if [ "$(id -u)" != "0" ]; then
    echo "Please run this  script as root."
    echo "Usage: sudo ./install.sh"
    exit 1
fi

LE_LOCATION="https://raw.github.com/logentries/le/master/le"

CURL="/usr/bin/env curl -O"

LOGGER_CMD="logger -t LogentriesTest Test Message Sent By LogentriesAgent"
DAEMON="com.logentries.agent.plist"
DAEMON_DL_LOC="https://raw.github.com/logentries/le/master/install/mac/$DAEMON"
DAEMON_PATH="/Library/LaunchDaemons/"

INSTALL_PATH="/usr/bin/le"
REGISTER_CMD="$INSTALL_PATH register --account-key=$1"
[[ -z $1 ]] && REGISTER_CMD="$INSTALL_PATH register"

LE_FOLLOW="$INSTALL_PATH follow"

printf "Welcome to the Logentries Install Script\n"

printf "Downloading dependencies...\n"
$CURL $LE_LOCATION
$CURL $DAEMON_DL_LOC

printf "Copying files...\n"
chmod +x le
chown root:wheel le
chown root:wheel $DAEMON
mv le $INSTALL_PATH
mv $DAEMON $DAEMON_PATH

$REGISTER_CMD

if [ "$(echo $?)" != "0" ]; then
    echo "Registration failed.  Please verify your account ID"
    echo "You can run install.sh with no arguments to be prompted for your email/password to register"
    echo "Enter your account ID as an argument. e.g. install.sh 2342342sdfwe23423423243423"
    exit 1
fi

$LE_FOLLOW "/var/log/system.log"

printf "\n**** Install Complete! ****\n\n"
printf "If you would like to monitor more files, simply run this command as root, 'le follow filepath', e.g. 'le follow /var/log/mylog.log'\n\n"
printf "And be sure to restart the agent service for new files to take effect, you can do this with the following two commands.\n"
printf "launchctl unload ${DAEMON_PATH}\n"
printf "launchctl load ${DAEMON_PATH}\n"
printf "For a full list of commands, run 'le --help' in the terminal.\n\n"

launchctl unload $DAEMON_PATH$DAEMON
launchctl load $DAEMON_PATH$DAEMON

printf "Starting agent"
i="0"
while [ $i -lt 40 ]
do
    sleep 0.05
    printf "."
    i=$[$i+1]
done

printf "DONE\n\nWe will now send some sample events to your new Logentries account. This will take about 10 seconds.\n\n"

l=1
while [ $l -le 100 ]
do
	logger "Logentries Test Event ${l}"
        printf "."
	sleep 0.1
	l=$(( $l + 1 ))
done
printf "DONE\n"

exit 0
