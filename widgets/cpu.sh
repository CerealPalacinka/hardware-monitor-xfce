#!/usr/bin/env bash

readonly SCRIPT_DIR=$(dirname "$(realpath $0)")

readonly COLOR="#c4f9ff"
# Portable directory
readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Available CPUs - threads are looked at as cores
declare -r CPU_ARRAY=($(awk '/MHz/{print $4}' /proc/cpuinfo | cut -f1 -d"."))
# Tempretature
readonly CPU_TEMP=$(sensors | grep -A 0 Tctl | cut -f2- -d: | sed "s/[^0-9'.]//g")


# Filterd CPU utalization per core
readonly MPSTAT_JSON=$(mpstat -o JSON -P ALL 1 1 | jq '100-.sysstat.hosts[].statistics[]."cpu-load"[].idle') # Convert idle value to core load
set -o noglob
IFS=$'\n' MPSTAT_ARRAY=($MPSTAT_JSON)
set +o noglob


# Tooltip
MORE_INFO="<tool>"
MORE_INFO+="$(grep "model name" /proc/cpuinfo | cut -f2 -d ":" | sed -n 1p | sed -e 's/^[ \t]*//')\n" # CPU vendor, model
MORE_INFO+="┌─\t\t\t  Live Data\n"


STEP=0 # to generate CPU numbers (eg. CPU0, CPU1 ...)
for CPU in "${CPU_ARRAY[@]}" 
do
  UTIL=${MPSTAT_ARRAY[(STEP + 1)]}

  MORE_INFO+="├─ CPU ${STEP}:\t\t\t\t  $(printf '%3d' $UTIL)%\n"

  let STEP+=1
done
MORE_INFO+="└─ Temperature:\t\t  $(printf '%3d' $CPU_TEMP)°C"
MORE_INFO+="</tool>"

UTIL_ALL=${MPSTAT_ARRAY[0]}

COLOR_UTIL=$(python3 $SCRIPT_DIR/.color.py $UTIL_ALL)
COLOR_TEMP=$(python3 $SCRIPT_DIR/.color.py $CPU_TEMP)

INFO="<txt><span foreground='$COLOR'>"
INFO+=" Util:<span foreground='$COLOR_UTIL'>$(printf '%3d' $UTIL_ALL)%</span>"
INFO+=" | Temp:<span foreground='$COLOR_TEMP'>$(printf '%3d' $CPU_TEMP)°C </span>"
INFO+="</span></txt>"

# Output panel
echo -e "${INFO}"

# Output hover menu
echo -e "${MORE_INFO}"