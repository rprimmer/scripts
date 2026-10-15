#!/bin/sh
ps -ef | grep sh | grep -v grep | grep -v "/bin/sh shells"
