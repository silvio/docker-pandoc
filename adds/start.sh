#!/usr/bin/env bash

echo "commandline: $*"

PUID="${PUID:-0}"
PGID="${PGID:-0}"

if [ "$1" == "exec" ]; then
	shift
	$*

	exit $?
fi

if [ "${1}" == "server" ]; then
	shift

	PANDOCOPTIONS=""
	for arg in ${*}
	do
		[ "${arg}" == "--" ] && break
		PANDOCOPTIONS="${PANDOCOPTIONS} ${arg}"
		shift
	done

	shift

	SUFFIX="${1}"
	shift
	FILES=${*}

	COUNTER=0

	while true
	do
		CHANGEDFILE=$(inotifywait -q --format '%w' -e 'close_write' ${FILES})
		OUT=$?

		case "${OUT}" in
			"0")
				COUNTER=$(( ++COUNTER ))
				(
					pandoc ${PANDOCOPTIONS} ${CHANGEDFILE} -o ${CHANGEDFILE}.${SUFFIX}
					chown ${PUID}:${PGID} ${CHANGEDFILE}.${SUFFIX}
					printf "(%4d) :: %30s -> %-30s (\$?: $?)\n" ${COUNTER} ${CHANGEDFILE} ${CHANGEDFILE}.${SUFFIX}
				) &
				;;
			*)
				exit
				;;
		esac
	done
fi

if [ "$1" = "--help" -o "$1" = "-h" ]; then
	echo ""
	echo "# You can execute this docker container with 'exec' to start other programs than pandoc,"
	echo "# or with 'server <pandocoptions> -- <suffix> <file1> [ ... <fileN> ]' to watch the "
	echo "# <fileN>'s of changes and generate the output <fileN>.suffix"
	echo ""
	echo "# example:"
	echo "#   \${dockerblah} exec bash"
	echo "#   \${dockerblah} server  -- pdf a.md b.md c.md"
	echo ""
	if [ -e /installed-pandocfilters.txt ]; then
		echo "# This filters are installed on the pandoc image:"
		for FILTER in $(< /installed-pandocfilters.txt)
		do
			echo "#   ${FILTER}"
		done
	fi
fi

pandoc $*

FILENAME=$(echo $* | sed 's/.*\(-o\ \|--output=|--output\ \)\([[:graph:]]*\).*/\2/')
[[ -n "${FILENAME}" ]] && chown ${PUID}:${PGID} ${FILENAME}
