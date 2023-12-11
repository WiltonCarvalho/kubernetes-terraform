#!/bin/sh
set -e
sudo /dockerd.sh --
exec lxterminal -e "tmux -u"