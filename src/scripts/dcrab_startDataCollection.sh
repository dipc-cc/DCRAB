#!/bin/bash

# Redirect all the output to DCRAB log file
exec >> $4 

echo "--- DCRAB `hostname` log ---" 2>&1

# Save hostname of the node
node_hostname=`hostname`
node_hostname_mod=`echo $node_hostname | sed 's|-||g'`

# Sets environment
source "$1"

# Move to the working directory
cd $DCRAB_WORKDIR

# Source modules
source $DCRAB_BIN/modules/cpu/dcrab_cpu.sh
source $DCRAB_BIN/scripts/dcrab_config.sh

# Save hostname of the node
node_hostname=`hostname`
node_hostname_mod=`echo $node_hostname | sed 's|-||g'`

# Save the line to inject CPU data
node_data_line=`grep -n -m 1 "\/\* $node_hostname_mod data space \*\/" $DCRAB_REPORT_DIR/dcrab_report.html | cut -f1 -d:`
node_addColumn_line=`grep -n -m 1 "\/\* $node_hostname_mod addColumn space \*\/" $DCRAB_REPORT_DIR/dcrab_report.html | cut -f1 -d:`

cpu_inject_line=$((node_data_line + 2))
addColumn_line=$$((node_addColumn_line + 1))


# Sleep first time to desynchronize with other nodes
sleep "$3"

dcrab_determine_main_process $DCRAB_REPORT_DIR/data/dcrab_cpu_$node_hostname.txt

loopNumber=1
updates=0
while [ 1 ]; do
	
	echo "$node_hostname - loop $loopNumber" 

	# Update and collect data
	dcrab_update_data $DCRAB_REPORT_DIR/data/dcrab_cpu_$node_hostname.txt

	# Insert CPU data in the main .html page
	write_data $cpu_inject_line $addColumn_line $cpu_data

	loopNumber=$((loopNumber + 1))

	# Sleep to the next data collection
	sleep $DCRAB_COLLECT_TIME
done
