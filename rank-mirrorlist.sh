#!/bin/sh -eu

progname=rank-mirrorlist

usage()
{
printf '%s' "\
Usage: $progname [-a ARCH] [-r REPO] [-t TIMEOUT]
           [-c COUNTRIES]... [FILE...]

Rank mirrors from input FILEs from specified COUNTRIES.
COUNTRIES is a list of basic regular expressions separated by newlines.

  -a ARCH       string to replace '\$arch' variable in urls with
  -r REPO       string to replace '\$repo' variable in urls with
  -t TIMEOUT    connection timeout
  -c COUNTRIES  list of countries
  -h            print help
" >&2
}

sed_escape()
{
	printf '%s' "$*" | sed 's|[\/&]|\\&|g; q'
}

NL='
'

while getopts 'a:r:t:n:c:h' OPT; do
	case "$OPT" in
	a) arch="$OPTARG" ;;
	r) repo="$OPTARG" ;;
	t) timeout="$OPTARG" ;;
	c) countries="${countries-}$OPTARG$NL" ;;
	h) usage; exit 0 ;;
	*) usage; exit 2 ;;
	esac
done
shift "$(( OPTIND - 1 ))"

arch="$(sed_escape "${arch:-$(uname -m)}")"
repo="$(sed_escape "${repo:-core}")"
timeout="${timeout:-10}"

sed_countries="$(printf '%s' "${countries-}" |
                 sed -e 's|\\/|/|g; s|/|\\/|g' \
                     -e 's|.*|/^## &$/,/^$/s/^#*Server *= *//p;|')"

sed -n -e "$sed_countries" -- "$@" |
sed -e "h; s/\$arch/$arch/g; s/\$repo/$repo/g" \
    -e 's/[\"]/\\&/g; s/.*/url "&"/p' \
    -e 'g; s/[\"]/\\&/g; s|.*|output "/dev/null/&"|' |
curl -s -L -Z -K - -m "$timeout" \
     -w '%{time_total} %{http_code} %{filename_effective}\n' |
sort -n |
sed -n 's|^[^ ]* 200 /dev/null/|Server = |p'
