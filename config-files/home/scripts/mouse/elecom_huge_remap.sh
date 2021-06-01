#!/bin/sh 

# Elecom Huge Trackball Mapping
ELECOM_ID=$(xinput list | grep "ELECOM" | head -n 1 | sed -r 's/.*id=([0-9]+).*/\1/')
xinput --set-button-map ${ELECOM_ID} 1 2 3 4 5 6 7 8 9 10 11 2
