#!/bin/bash
INTERFACE="$3"
/sbin/brctl delif tunneldigger $INTERFACE
exit 0
