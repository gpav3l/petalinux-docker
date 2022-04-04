#!/bin/bash

PARAMS=""
 
while (( "$#" )); do
  case "$1" in
    -w|--workspace)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PL_WORKSPACE=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
 
# set positional arguments in their proper place
eval set -- "$PARAMS"

if [[ ! -z $PL_WORKSPACE ]] && [ -d $PL_WORKSPACE ]; then
	echo "Try open contianer for WS $PL_WORKSPACE"
else
	if [[ -z $PL_WORKSPACE ]]; then 
		echo "No folder pass, (miss flag -w ?)"
	elif [ ! -d $PL_WORKSPACE ]; then 
		echo "Folder $PL_WORKSPACE not found"
	fi
		
fi

docker run -ti --rm -e DISPLAY=$DISPLAY --net="host" -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/vivado/.Xauthority -v $PL_WORKSPACE:/home/vivado/project petalinux:2020.2 /bin/bash 
