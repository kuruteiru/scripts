#!/bin/bash

if [[ $1 == "" ]]; then
	echo "no argument given"
elif [[ $1 == "-h" ]]; then
	echo "audio output changed to headphones"
    for stream in $(pactl list short sink-inputs | awk '{print $1}'); do 
        pactl move-sink-input $stream "alsa_output.usb-Logitech_PRO_X_000000000000-00.analog-stereo"; 
    done
elif [[ $1 == "-s" ]]; then
	echo "audio output changed to speakers"
    for stream in $(pactl list short sink-inputs | awk '{print $1}'); do 
            pactl move-sink-input $stream "alsa_output.pci-0000_2d_00.4.analog-stereo"; 
    done
fi
