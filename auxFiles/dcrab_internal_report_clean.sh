#!/bin/bash -e
# DCRAB SOFTWARE
# Version: 2.0
# Autor: CC-staff
# Donostia International Physics Center
#
# ===============================================================================================================
#
# This script recollects all the data generated by all the DCRAB jobs into one file to decrease the number
# of folders. The file will be located in the same location as the jobs folder
#
# ===============================================================================================================

DCRAB_IREPORT_DATA_DIR="/scratch/administracion/admin/dcrab/data"
DCRAB_IREPORT_DATA_BACKUP_DIR="/scratch/administracion/admin/dcrab/dataBackup"
DCRAB_IREPORT_JOB_DIR="/scratch/administracion/admin/dcrab/job"
randomChars=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
DCRAB_IREPORT_COLLECT_FILE="dcrab_ireport_collected_data_$(date +%d%m%Y)_${randomChars}.txt"
DCRAB_IREPORT_TAR_FILE="dcrab_ireport_collected_jobs_$(date +%d%m%Y)_${randomChars}.tar.gz"
DCRAB_IREPORT_TAR_FILE2="dcrab_ireport_collected_jobs_dir_$(date +%d%m%Y)_${randomChars}.tar.gz"
selectedJobs=""
selectedJobs2=""
errorJobs=""
errorJobs2=""

cd $DCRAB_IREPORT_DATA_DIR

echo "Collecting all the data . . . (1/8)"
:> $DCRAB_IREPORT_COLLECT_FILE
while read i; do 
	jobid=${i##*/}

	date=$(ls -lt --time-style="+%s" $jobid 2> /dev/null | grep -v total | head -1 | sed 's|\s\s*| |g' |  cut -d' ' -f6 )
	content=$(cat $jobid)
	ibValue=$(echo $content | cut -d ' ' -f3)
	
	if [ $ibValue -ge 0 ]; then
		printf "%s %s\n" "$content $date" >> $DCRAB_IREPORT_COLLECT_FILE
		selectedJobs="$selectedJobs $jobid"
		if [ -d $DCRAB_IREPORT_JOB_DIR/$jobid ]; then
			selectedJobs2="$selectedJobs2 $jobid"
		fi
	else 
		echo "Error in the job ${jobid}. Omitting directory"
		errorJobs="$errorJobs $jobid"
		if [ -d $DCRAB_IREPORT_JOB_DIR/$jobid ]; then
			errorJobs2="$errorJobs2 $jobid"
		fi
	fi
done < <(find . -maxdepth 1 -mtime +1)

# Make the tar
echo "Making the tar of the data files. . . (2/8)"
tar czf $DCRAB_IREPORT_TAR_FILE $selectedJobs
echo "Moving the files . . . (3/8)"
mv $DCRAB_IREPORT_TAR_FILE $DCRAB_IREPORT_COLLECT_FILE $DCRAB_IREPORT_DATA_BACKUP_DIR

cd $DCRAB_IREPORT_JOB_DIR
echo "Making the tar of jobs' folders . . . (4/8)"
tar czf $DCRAB_IREPORT_TAR_FILE2 $selectedJobs2
echo "Moving the files . . . (5/8)"
mv $DCRAB_IREPORT_TAR_FILE2 $DCRAB_IREPORT_DATA_BACKUP_DIR

# Delete the files
cd $DCRAB_IREPORT_DATA_DIR
echo "Deleting data files . . . (6/8)"
\rm -f $selectedJobs $errorJobs

cd $DCRAB_IREPORT_JOB_DIR
echo "Deleting jobs' folders . . . (7/8)"
\rm -rf $selectedJobs2 $errorJobs2

echo "Cleaning folders which has no data file . . . (8/8)"
for i in *; do
	if [ ! -e ${DCRAB_IREPORT_DATA_DIR}/$i ]; then
		echo "Removing $i job"		
		rm -rf $i
	fi
done

