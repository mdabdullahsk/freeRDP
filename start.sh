#!/bin/bash

# DBUS সার্ভিস চালু করা
service dbus start

# PulseAudio সিস্টেম মোডে চালু করা
pulseaudio --start --system --disallow-exit --disable-shm --realtime=no

# XRDP সার্ভিস চালু করা
service xrdp start

# X11 permissions ঠিক করা
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# কনটেইনার সচল রাখা
tail -f /var/log/xrdp-sesman.log
