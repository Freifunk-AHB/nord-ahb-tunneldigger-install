#!/bin/bash

WDIR=/srv/tunneldigger/broker
VIRTUALENV_DIR=/srv/tunneldigger

cd $WDIR
source $VIRTUALENV_DIR/bin/activate
$VIRTUALENV_DIR/bin/python l2tp_broker.py l2tp_broker.cfg
