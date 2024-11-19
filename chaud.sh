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
            pactl move-sink-input $stream "alsa_output.usb-Lenovo_ThinkPad_Thunderbolt_4_Dock_USB_Audio_000000000000-00.analog-stereo"
    done
elif [[ $1 == "-ls" ]]; then
	echo "audio output changed to laptop speakers"
    for stream in $(pactl list short sink-inputs | awk '{print $1}'); do 
            pactl move-sink-input $stream "alsa_output.pci-0000_c3_00.6.HiFi__Speaker__sink"
    done
fi
