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

	# Options before '--' for pandoc
	PANDOCOPTIONS=""
	for arg in ${*}
	do
		[ "${arg}" == "--" ] && break
		PANDOCOPTIONS="${PANDOCOPTIONS} ${arg}"
		shift
	done

	shift

	# Options after '--' for server settings
	OUTFOLDER="."
	for arg in ${*}
	do
		case ${arg} in
			(--output-folder=*)
				OUTFOLDER=$(echo $arg | cut -d "=" -f 2)
				shift
				;;
			(*)
				break
				;;
		esac
	done

	SUFFIX="${1}"
	shift

	COUNTER=0

	while true
	do
		CHANGEDFILE=$(inotifywait -q --format '%w' -e 'close_write' ${*})
		OUT=$?

		case "${OUT}" in
			"0")
				COUNTER=$(( ++COUNTER ))
				(
					pandoc ${PANDOCOPTIONS} ${CHANGEDFILE} -o ${OUTFOLDER}/${CHANGEDFILE}.${SUFFIX}
					if [ -e ${OUTFOLDER}/${CHANGEDFILE}.${SUFFIX} ]; then
						chown ${PUID}:${PGID} ${OUTFOLDER}/${CHANGEDFILE}.${SUFFIX}
					fi
					printf "(%4d) :: %30s -> %-30s (\$?: $?)\n" ${COUNTER} ${CHANGEDFILE} ${OUTFOLDER}/${CHANGEDFILE}.${SUFFIX}
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
	echo "# or with 'server [pandocoptions] -- [serveroptions] <suffix> <file1> [ ... <fileN> ]' to watch the "
	echo "# <fileN>'s of changes and generate the output <fileN>.suffix"
	echo ""
	echo "# serveroptions:"
	echo "#   --output-folder=<folder>  outputfile should placed in <folder>"
	echo ""
	echo "# example:"
	echo "#   \${dockerblah} exec bash"
	echo "#   \${dockerblah} server  -- pdf a.md b.md c.md"
	echo "#   \${dockerblah} server  -- --output-folder=output pdf a.md b.md c.md"
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
if [ -n "${FILENAME}" ] && [ -e "${FILENAME}" ]; then
	chown ${PUID}:${PGID} ${FILENAME}
fi
