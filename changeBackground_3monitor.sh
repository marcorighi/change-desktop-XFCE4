#!/bin/bash

# created by Marco
export LC_TIME="en_US.UTF-8"


if [ -z "$1" ]; then
  echo ERROR: missing config file
  echo $0 configfile sleeptime
  exit 1
fi

if [ -z "$2" ]; then
  echo "ERROR: missing sleep time (seconds)"
  echo $0 configfile sleeptime
  exit 1
fi

if [ ! -f "$1" ]; then
  echo ERROR file \"$1\" does not exists
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
        echo "counter file \"${COUNTER_FILE}\" found "
        source "${COUNTER_FILE}"
    else
        echo "counter file \"${COUNTER_FILE}\" not found found. Init variables to 0 "
        MONITOR2_COUNTER=0
        MONITOR1_COUNTER=0
        MONITOR3_COUNTER=0
    fi
}

# Function to save counters in the configuration file
save_counters() {
    echo "MONITOR2_COUNTER=${MONITOR2_COUNTER}" > "${COUNTER_FILE}"
    echo "MONITOR1_COUNTER=${MONITOR1_COUNTER}" >> "${COUNTER_FILE}"
    echo "MONITOR3_COUNTER=${MONITOR3_COUNTER}" >> "${COUNTER_FILE}"
}

# Function to increase the counter with the module of the maximum number of images
increment_counter() {
    local counter=$1
    local max=$2
    echo $(( (counter + 1) % max ))
}

# Read counters from configuration file
read_counters

# Populate the image arrays
MONITOR1_imgs=($(ls "${MONITOR1_DIR}"))
MONITOR2_imgs=($(ls "${MONITOR2_DIR}"))
MONITOR3_imgs=($(ls "${MONITOR3_DIR}"))

MONITOR1_max=${#MONITOR1_imgs[@]}
MONITOR2_max=${#MONITOR2_imgs[@]}
MONITOR3_max=${#MONITOR3_imgs[@]}

echo MONITOR1 max= ${MONITOR1_max} |tee $LOG
echo MONITOR1 counter= ${MONITOR1_COUNTER} |tee -a $LOG
echo MONITOR2 max= ${MONITOR2_max} |tee -a $LOG
echo MONITOR2 counter= ${MONITOR2_COUNTER} |tee -a $LOG
echo MONITOR3 max= ${MONITOR3_max} |tee -a $LOG
echo MONITOR3 counter= ${MONITOR3_COUNTER} |tee -a $LOG

# Function to change the background image
change_wallpapers() {
    echo background changed $(date)|tee -a $LOG

    # Select images by counter
    MONITOR1_IMG="${MONITOR1_DIR}/${MONITOR1_imgs[${MONITOR1_COUNTER}]}"
    MONITOR2_IMG="${MONITOR2_DIR}/${MONITOR2_imgs[${MONITOR2_COUNTER}]}"
    MONITOR3_IMG="${MONITOR3_DIR}/${MONITOR3_imgs[${MONITOR3_COUNTER}]}"

    properties=$(xfconf-query -c xfce4-desktop -l | grep 'last-image')

    for property in $properties; do
        if [[ "${property}" =~ "${MONITOR1}" ]]; then
            IMAGE_PATH=$MONITOR1_IMG
        fi
        if [[ "${property}" =~ "${MONITOR2}" ]]; then
            IMAGE_PATH=$MONITOR2_IMG
        fi
        if [[ "${property}" =~ "${MONITOR3}" ]]; then
            IMAGE_PATH=$MONITOR3_IMG
        fi

        xfconf-query -c xfce4-desktop -p "$property" -s "$IMAGE_PATH"
        style_property=$(echo "$property" | sed 's/last-image/image-style/')
        xfconf-query -c xfce4-desktop -p "$style_property" -s 3  # 3 = Scaled
    done


    # Increase counters
    MONITOR1_COUNTER=$(increment_counter ${MONITOR1_COUNTER} $MONITOR1_max)
    MONITOR2_COUNTER=$(increment_counter ${MONITOR2_COUNTER} $MONITOR2_max)
    MONITOR3_COUNTER=$(increment_counter ${MONITOR3_COUNTER} $MONITOR3_max)

    # Save the counters in the configuration file
    save_counters
}

# Change images every [parameter $2] minutes
while true; do
    change_wallpapers
    sleep $sleep_time
done
