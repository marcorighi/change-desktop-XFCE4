#!/bin/bash
export LC_TIME="en_US.UTF-8"

if [ -z "$1" ]; then
  echo "ERROR: missing config file"
  echo "$0 configfile sleeptime"
  exit 1
fi

if [ -z "$2" ]; then
  echo "ERROR: missing sleep time (seconds)"
  echo "$0 configfile sleeptime"
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "ERROR: file \"$1\" does not exist"
  exit 1
fi

sleep_time=$2

config_file="$1"
source "$config_file"

file_name=$(basename "$config_file")
file_name=${file_name%.*}

# Configuration file for counters
COUNTER_FILE=~/log/${file_name}_counters.txt
LOG=~/log/${file_name}.log

# Function to read counters from the configuration file
read_counters() {
    if [[ -f "${COUNTER_FILE}" ]]; then
        echo "Counter file \"${COUNTER_FILE}\" found"
        source "${COUNTER_FILE}"
    else
        echo "Counter file \"${COUNTER_FILE}\" not found. Initializing variables to 0"
        MONITOR2_COUNTER=0
        MONITOR1_COUNTER=0
        MONITOR3_COUNTER=0
    fi
}

# Function to save counters to the configuration file
save_counters() {
    echo "MONITOR2_COUNTER=${MONITOR2_COUNTER}" > "${COUNTER_FILE}"
    echo "MONITOR1_COUNTER=${MONITOR1_COUNTER}" >> "${COUNTER_FILE}"
    echo "MONITOR3_COUNTER=${MONITOR3_COUNTER}" >> "${COUNTER_FILE}"
}

# Function to increment the counter with modulo of the maximum number of images
increment_counter() {
    local counter=$1
    local max=$2
    echo $(( (counter + 1) % max ))
}

# Check if directories exist and are not empty
if [ ! -d "${MONITOR1_DIR}" ] || [ ! "$(ls -A ${MONITOR1_DIR})" ]; then
    echo "ERROR: MONITOR1_DIR is either missing or empty"
    exit 1
fi

if [ ! -d "${MONITOR2_DIR}" ] || [ ! "$(ls -A ${MONITOR2_DIR})" ]; then
    echo "ERROR: MONITOR2_DIR is either missing or empty"
    exit 1
fi

if [ ! -d "${MONITOR3_DIR}" ] || [ ! "$(ls -A ${MONITOR3_DIR})" ]; then
    echo "ERROR: MONITOR3_DIR is either missing or empty"
    exit 1
fi

# Read counters from the configuration file
read_counters

# Populate the image arrays
MONITOR1_imgs=($(ls "${MONITOR1_DIR}"))
MONITOR2_imgs=($(ls "${MONITOR2_DIR}"))
MONITOR3_imgs=($(ls "${MONITOR3_DIR}"))

MONITOR1_max=${#MONITOR1_imgs[@]}
MONITOR2_max=${#MONITOR2_imgs[@]}
MONITOR3_max=${#MONITOR3_imgs[@]}

echo "MONITOR1 max= ${MONITOR1_max}" | tee $LOG
echo "MONITOR1 counter= ${MONITOR1_COUNTER}" | tee -a $LOG
echo "MONITOR2 max= ${MONITOR2_max}" | tee -a $LOG
echo "MONITOR2 counter= ${MONITOR2_COUNTER}" | tee -a $LOG
echo "MONITOR3 max= ${MONITOR3_max}" | tee -a $LOG
echo "MONITOR3 counter= ${MONITOR3_COUNTER}" | tee -a $LOG


list_worspace_names(){
    monitorToCheck=$1
    xfconf-query -c xfce4-desktop -l | grep "$monitorToCheck" | grep "last-image"| sed 's/.*workspace/workspace/g'|sed 's/\/.*//g'
}

# Function to change the wallpaper
change_wallpapers() {
    echo "Background changed $(date)" | tee -a $LOG



    # Percorsi delle immagini
    MONITOR1_IMG="${MONITOR1_DIR}/${MONITOR1_imgs[${MONITOR1_COUNTER}]}"
    MONITOR2_IMG="${MONITOR2_DIR}/${MONITOR2_imgs[${MONITOR2_COUNTER}]}"
    MONITOR3_IMG="${MONITOR3_DIR}/${MONITOR3_imgs[${MONITOR3_COUNTER}]}"

    # Aggiorna SOLO i percorsi principali (workspace0) per ogni monitor
#     xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor0/workspace0/last-image" -s "$MONITOR1_IMG" 2>/dev/null
#     xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitorDP-1-1/workspace0/last-image" -s "$MONITOR2_IMG" 2>/dev/null
#     xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitorDP-1-3/workspace0/last-image" -s "$MONITOR3_IMG" 2>/dev/null

#    echo xfconf-query -c xfce4-desktop -p \"/backdrop/screen0/${MONITOR1}/workspace0/last-image\" -s \"$MONITOR1_IMG\" 2>/dev/null

     echo "Elenco dei nomi degli spazi di lavoro:"

     MONITOR="${MONITOR1}"
     workspace_names=$(list_worspace_names "${MONITOR}")

     for name in $workspace_names; do
           echo "$name"
           xfconf-query -c xfce4-desktop -p "/backdrop/screen0/${MONITOR}/${name}/last-image" -s "$MONITOR1_IMG" 2>/dev/null
     done

     MONITOR="${MONITOR2}"
     workspace_names=$(list_worspace_names "${MONITOR}")

     for name in $workspace_names; do
           echo "$name"
           xfconf-query -c xfce4-desktop -p "/backdrop/screen0/${MONITOR}/${name}/last-image" -s "$MONITOR2_IMG" 2>/dev/null
     done

     MONITOR="${MONITOR3}"
     workspace_names=$(list_worspace_names "${MONITOR}")

     for name in $workspace_names; do
           echo "$name"
           xfconf-query -c xfce4-desktop -p "/backdrop/screen0/${MONITOR}/${name}/last-image" -s "$MONITOR3_IMG" 2>/dev/null
     done
    # Opzionale: Forza il refresh degli sfondi
    xfdesktop --reload

    # Incrementa i contatori
    MONITOR1_COUNTER=$(increment_counter ${MONITOR1_COUNTER} $MONITOR1_max)
    MONITOR2_COUNTER=$(increment_counter ${MONITOR2_COUNTER} $MONITOR2_max)
    MONITOR3_COUNTER=$(increment_counter ${MONITOR3_COUNTER} $MONITOR3_max)

    save_counters
}

# Change the images every sleep_time seconds
while true; do
    change_wallpapers
    sleep $sleep_time
done
