#!/bin/sh -eu

dbpath=/var/lib/pacman/update
logfile=/var/log/checkupdate.log

mkdir -p -- "$dbpath"
ln -s -f -- "$(pacman-conf DBPath)/local" "$dbpath"
pacman --dbpath "$dbpath" --logfile "$logfile" --noconfirm -Syuuw
