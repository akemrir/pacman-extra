#!/bin/sh -eu

progname=pkgrepo

usage()
{
printf '%s' "\
Usage: $progname ...
...
" >&2
}

TMP="/tmp/pkgrepo.$$"
PKGBUILD="$TMP/PKGBUILD"
PKG=/usr/share/pkgrepo/pkg
REPO=/var/lib/pacman/repo/custom/x86_64
DB="$REPO/custom.db.tar.gz"

mkdir -- "$TMP"
cd -- "$TMP"

cp -f -- "$PKG/pkg/packages" "$PKGBUILD"
makepkg -f -c -C -d
fname="$(echo packages-20*.tar.xz)"
if [ ! -e "$REPO/$fname" ]; then
	sudo cp -f -- "$fname" "$REPO"
	sudo repo-add "$DB" "$fname"
	sudo pacman -Sy packages
fi

for file in $(find -L "$PKG" -type f); do
	cp -f -- "$file" "$PKGBUILD"
	makepkg -f -c -C -d
	fname="$(echo $(basename -- "$file")-20*.tar.xz)"
	if [ ! -e "$REPO/$fname" ]; then
		sudo cp -f -- "$fname" "$REPO"
		sudo repo-add "$DB" "$fname"
	fi
done
