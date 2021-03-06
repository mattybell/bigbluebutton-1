#!/usr/bin/bash

function cleanup {
echo "Cleaning up..."

echo "Closing browser"
kill $browser_pid
sleep 1

if [ -f /tmp/.X${DISPLAY:1}-lock ]; then
  echo "Closing xserver"
  xserver_pid=$(ps aux | grep `cat /tmp/.X${DISPLAY:1}-lock` | tail -n1 | rev | cut -d ' ' -f 1 | rev)
  kill $xserver_pid
  rm -rf /tmp/.X${DISPLAY:1}-lock
fi

echo "Exiting"
}
trap cleanup SIGINT SIGTERM EXIT

export DISPLAY=:1
OUTFILE=/tmp/capture.mp4
DURATION=5

# Start the X server
Xvfb $DISPLAY -screen 0 640x480x24 -ac &

# Run a browser to capture
firefox &
#google-chrome &
browser_pid=$!

# Capture display with ffmpeg for a set duration
if [ -f $OUTFILE ]; then
  rm $OUTFILE
fi
ffmpeg -framerate 12 -s 640x480 -f x11grab -t $DURATION -i $DISPLAY -g 24 -preset veryfast -tune zerolatency -r 12 -c:v libx264 -crf 24 -pix_fmt yuv420p $OUTFILE

