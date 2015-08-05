#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Docker - pyenv v201508041108
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/docker/pyenv

Example usage of compile+install, and subsequent test of desired version:
$] pycompiler.bash VERSION
$] python --version

!COMMENT

target=$(echo "$1" | tr -d '[[:space:]]')
rexp='^TARGET\.[0-9][\.0-9]*$'
pylist=$( pyenv install --list )

echo "----------"
echo "$pylist"
echo "----------"

if [ "${#target}" == 1 ] || [ "$target" == "latest" ] || [ -z "$target" ]; then
	case $target in
			[2-3]*)
				pyrexo="${rexp/TARGET/$target}";;
			*)
				pyrexo="${rexp/TARGET/[0-9]}";;
		esac

	if [ -z "$target" ]; then
		echo "You can select a specific version by editing the 'version' file that's in your Dockerfile directory."
		echo "----------"
	fi

	pyver=$( echo "$pylist" | sed -e 's/^[[:space:]]*//' | grep --regexp $pyrexo | sort --version-sort | tail -n 1 )

else
	pyver=$target
fi
unset target rexp pylist pyrexo

echo "Installing Python $pyver, and setting as global Python interpreter:"

pyenv install $pyver
pyenv global $pyver

unset pyver
