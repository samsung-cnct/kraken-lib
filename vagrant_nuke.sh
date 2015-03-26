#!/bin/bash

# Nuclear option for vagrant when things don't startup quite right

# Kill runaway vagrant process
echo "Killing vagrant process"
kill $(ps aux | grep "vagrant up" | awk '{print $2}') > /dev/null 2>&1
echo "vagrant process terminated"

# Kill all virtual box instances
