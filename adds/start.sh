#!/usr/bin/env bash

echo "commandline: $*"

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
					/root/.cabal/bin/pandoc ${PANDOCOPTIONS} ${CHANGEDFILE} -o ${CHANGEDFILE}.${SUFFIX}
					printf "(%4d) :: %30s -> %-30s (\$?: $?)\n" ${COUNTER} ${CHANGEDFILE} ${CHANGEDFILE}.${SUFFIX}
				) &
				;;
			*)
				exit
				;;
		esac
	done
fi

if [ "$1" == "--help" ]; then
	echo ""
	echo "# You can execute this docker container with 'exec' to start other programs than pandoc,"
	echo "# or with 'server <pandocoptions> -- <suffix> <file1> [ ... <fileN> ]' to watch the "
	echo "# <fileN>'s of changes and generate the output <fileN>.suffix"
	echo ""
	echo "# example:"
	echo "#   \${dockerblah} exec bash"
	echo "#   \${dockerblah} server  -- pdf a.md b.md c.md"
	echo ""
fi

/root/.cabal/bin/pandoc $*
