#!/bin/bash

set -x

cat /etc/pip.conf

sudo iptables -A OUTPUT -d pypi.python.org -j DROP

sudo pip install --verbose shade
