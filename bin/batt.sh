#!/bin/sh

state=`sysctl hw.acpi.battery.state | awk '{print $2}'`
loaded=`sysctl hw.acpi.battery.life | awk '{print $2}'`

if test "$state" = "1"; then
    echo "Batt: ${loaded}%"
else
    echo "220V"
fi
