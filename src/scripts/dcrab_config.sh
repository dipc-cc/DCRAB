#!/bin/bash


dcrab_save_environment () {

        declare -p | grep "$1" >> $DCRAB_REPORT_DIR/aux/env.txt
}

dcrab_generate_html (){

	plot_width=800
	plot_height=600

	DCRAB_HTML=$DCRAB_REPORT_DIR/dcrab_report.html

	# Copy necessary files to generate html
	cp $DCRAB_BIN/aux/htmlResources/* $DCRAB_REPORT_DIR/aux/htmlResources
	
        # Generate the first steps of the report
        printf "%s \n" "<html>" >> $DCRAB_HTML
        printf "%s \n" "<head><title>DCRAB REPORT</title>" >> $DCRAB_HTML
	printf "%s \n" "<script type=\"text/javascript\" src=\"https://www.gstatic.com/charts/loader.js\"></script> " >> $DCRAB_HTML
	printf "%s \n" "<script type=\"text/javascript\"> " >> $DCRAB_HTML

	# Load packages and callbacks for plot functions
	printf "%s \n" "google.charts.load('current', {'packages':['line']}); " >> $DCRAB_HTML
        printf "%s \n" "google.charts.setOnLoadCallback(plot_cpu); " >> $DCRAB_HTML

	################# CPU plot function #################
        printf "%s \n" "function plot_cpu() { " >> $DCRAB_HTML
	# Data of each nodes
        for node in $DCRAB_NODES_MOD
        do
		# Variables to store data declaration (where the nodes will inject collected data)
		printf "%s \n" "/* $node data space */" >> $DCRAB_HTML
		printf "%s \n" "var cpu_$node = [" >> $DCRAB_HTML
		printf "%s \n" "[0, 0, 0]," >> $DCRAB_HTML
		printf "%s \n" "];" >> $DCRAB_HTML
		printf "%s \n" "var mem_$node ;" >> $DCRAB_HTML
		
		printf "%s \n" "var data_$node = new google.visualization.DataTable(); " >> $DCRAB_HTML

		printf "%s \n" "/* $node addColumn space */" >> $DCRAB_HTML
		printf "%s \n" "data_$node.addColumn('number', 'Execution Time (s)'); " >> $DCRAB_HTML
        	printf "%s \n" "data_$node.addColumn('number', 'core 0 '); " >> $DCRAB_HTML
        	printf "%s \n" "data_$node.addColumn('number', 'core 1 '); " >> $DCRAB_HTML
	        printf "%s \n" "data_$node.addRows(cpu_$node)" >> $DCRAB_HTML
	done
        printf "%s \n" "var options = {  " >> $DCRAB_HTML
        printf "%s \n" "chart: { " >> $DCRAB_HTML
        printf "%s \n" "title: 'CPU Utilization', " >> $DCRAB_HTML
        printf "%s \n" "subtitle: 'in percentage'  " >> $DCRAB_HTML
        printf "%s \n" "}, " >> $DCRAB_HTML
        printf "%s \n" "legend: {position: 'none', textStyle: {fontSize: 16}}, " >> $DCRAB_HTML
        printf "%s \n" "width: $plot_width,  " >> $DCRAB_HTML
        printf "%s \n" "height: $plot_height,  " >> $DCRAB_HTML
        printf "%s \n" "axes: {  " >> $DCRAB_HTML
        printf "%s \n" "x: {  " >> $DCRAB_HTML
        printf "%s \n" "0: {side: 'top'}  " >> $DCRAB_HTML
        printf "%s \n" "}  " >> $DCRAB_HTML
        printf "%s \n" "},  " >> $DCRAB_HTML
       	printf "%s \n" "};" >> $DCRAB_HTML

        for node in $DCRAB_NODES_MOD
        do
	        printf "%s \n" "var chart_$node = new google.charts.Line(document.getElementById('plot_cpu_$node'));"  >> $DCRAB_HTML
        	printf "%s \n" "chart_$node.draw(data_$node, options);  " >> $DCRAB_HTML
        done
	printf "%s \n" "}" >> $DCRAB_HTML
        ################# END CPU plot function #################

        printf "%s \n" "</script>" >> $DCRAB_HTML

	################# Style #################
        printf "%s \n" "<style>" >> $DCRAB_HTML
        printf "%s \n" "div#cpu {" >> $DCRAB_HTML
        printf "%s \n" "overflow:auto;" >> $DCRAB_HTML
        printf "%s \n" "}" >> $DCRAB_HTML
        printf "%s \n" "" >> $DCRAB_HTML
        printf "%s \n" ".header {" >> $DCRAB_HTML
        printf "%s \n" "width: 800px;" >> $DCRAB_HTML
        printf "%s \n" "border: 1px solid rgba(254, 254, 254, 0.3);" >> $DCRAB_HTML
        printf "%s \n" "float: left;" >> $DCRAB_HTML
        printf "%s \n" "text-align: center;" >> $DCRAB_HTML
        printf "%s \n" "font-family: 'Roboto', sans-serif;" >> $DCRAB_HTML
        printf "%s \n" "font-size: 16px;" >> $DCRAB_HTML
        printf "%s \n" "color: #fff;" >> $DCRAB_HTML
        printf "%s \n" "text-transform: uppercase;" >> $DCRAB_HTML
        printf "%s \n" "vertical-align: middle;" >> $DCRAB_HTML
        printf "%s \n" "background-color: rgba(255,255,255,0.3);" >> $DCRAB_HTML
        printf "%s \n" "}" >> $DCRAB_HTML
        printf "%s \n" "" >> $DCRAB_HTML
        printf "%s \n" ".cpu_plot{" >> $DCRAB_HTML
        printf "%s \n" "border: 1px solid rgba(254, 254, 254, 0.3);" >> $DCRAB_HTML
        printf "%s \n" "}" >> $DCRAB_HTML
        printf "%s \n" "" >> $DCRAB_HTML
        printf "%s \n" ".space {" >> $DCRAB_HTML
        printf "%s \n" "width: 30px;" >> $DCRAB_HTML
        printf "%s \n" "border: 0px;" >> $DCRAB_HTML
        printf "%s \n" "background-color: none;" >> $DCRAB_HTML
        printf "%s \n" "}" >> $DCRAB_HTML
	printf "%s \n" "</style>" >> $DCRAB_HTML
	################# END Style #################

	# Job summary
        printf "%s \n" "<body background=\"./aux/htmlResources/background.png\">" >> $DCRAB_HTML
        printf "%s \n" "<center><h1>DCRAB REPORT - JOB $DCRAB_JOB_ID </h1></center>" >> $DCRAB_HTML
        printf "%s \n" "<br><br>" >> $DCRAB_HTML
        printf "%s \n" "Name of the job: $DCRAB_JOBNAME <br>" >> $DCRAB_HTML
        printf "%s \n" "JOBID: $DCRAB_JOB_ID <br>" >> $DCRAB_HTML
        printf "%s \n" "User: $USER <br>" >> $DCRAB_HTML
        printf "%s \n" "Working directory: $DCRAB_WORKDIR <br>" >> $DCRAB_HTML
        printf "%s \n" "Node list: <br>" >> $DCRAB_HTML
        printf "%s \n" "$DCRAB_NODES <br>" >> $DCRAB_HTML
	printf "%s \n" "<br><br><br><br>" >> $DCRAB_HTML

	################# CPU plots #################
        printf "%s \n" "<div id="cpu">" >> $DCRAB_HTML
        printf "%s \n" "<table>" >> $DCRAB_HTML
        printf "%s \n" "<tr>" >> $DCRAB_HTML
        for node in $DCRAB_NODES
        do      
	        printf "%s \n" "<td><div class=\"header\">$node</div></td>" >> $DCRAB_HTML
		printf "%s \n" "<td><div class=\"space\"></div></td>" >> $DCRAB_HTML
        done
        printf "%s \n" "</tr>" >> $DCRAB_HTML
        printf "%s \n" "</table>" >> $DCRAB_HTML
        printf "%s \n" "<table>" >> $DCRAB_HTML
        printf "%s \n" "<tr>" >> $DCRAB_HTML
        for node in $DCRAB_NODES_MOD
        do         
		printf "%s \n" "<td><div class=\"cpu_plot\" id='plot_cpu_$node'></div></td>" >> $DCRAB_HTML
                printf "%s \n" "<td><div class=\"space\"></div></td>" >> $DCRAB_HTML
        done
        printf "%s \n" "</tr>" >> $DCRAB_HTML
        printf "%s \n" "</table>" >> $DCRAB_HTML
        printf "%s \n" "</div>" >> $DCRAB_HTML
	################# END CPU plots #################

        printf "%s \n" "</body> " >> $DCRAB_HTML
        printf "%s \n" "</html> " >> $DCRAB_HTML
}

dcrab_check_scheduler () {

        # Check the scheduler system used and define host list
        if [ -n "$SLURM_NODELIST" ]; then
                DCRAB_SCHEDULER=slurm
                DCRAB_JOB_ID=$SLURM_JOB_ID
                DCRAB_WORKDIR=$SLURM_SUBMIT_DIR
                DCRAB_JOBNAME=$SLURM_JOB_NAME
                DCRAB_NODES=`scontrol show hostname $SLURM_NODELIST`
                DCRAB_NNODES=`scontrol show hostname $SLURM_NODELIST | wc -l`
        elif [ -n "$PBS_NODEFILE" ]; then
                DCRAB_SCHEDULER=pbs
                DCRAB_JOB_ID=$PBS_JOBID
                DCRAB_WORKDIR=$PBS_O_WORKDIR
                DCRAB_JOBNAME=$PBS_JOBNAME
                DCRAB_NODES=`cat $PBS_NODEFILE | sort | uniq`
                DCRAB_NNODES=`cat $PBS_NODEFILE | sort | uniq | wc -l`
        else
                DCRAB_SCHEDULER=none
                DCRAB_JOB_ID=`date +%s`
                DCRAB_WORKDIR=.
                DCRAB_JOBNAME="$USER.job"
                DCRAB_NODES=`hostname -a`
                DCRAB_NNODES=1
        fi
}

dcrab_start_report () {
	# Sets the delay to collect data 
        DCRAB_COLLECT_TIME=10
        # To try no overlap writes in the main .html we can try to asign the second in which the node
        # must make that write operation
        [[ "$DCRAB_NNODES" -eq 1 ]] && DCRAB_TIME_HOWOFTEN=0  || DCRAB_TIME_HOWOFTEN=$((DCRAB_COLLECT_TIME / DCRAB_NNODES))

	#tmp
	#DCRAB_NODES="atlas-104 atlas-105 atlas-106"
	
	# Remove '-' character of the names to create javascript variables
	DCRAB_NODES_MOD=`echo $DCRAB_NODES | sed 's|-||g'`

	# Create data folder 
	mkdir -p $DCRAB_REPORT_DIR/data
	
	# Create folder to save required files
	mkdir -p $DCRAB_REPORT_DIR/aux
        mkdir $DCRAB_REPORT_DIR/aux/htmlResources

	# Generate the first steps of the report
	dcrab_generate_html 

        # Save environment
        dcrab_save_environment "DCRAB_" 
}

dcrab_finalize () {

	# Restore environment
	source $DCRAB_REPORT_DIR/aux/env.txt
	
	# Load finalize functions
	source $DCRAB_BIN/scripts/dcrab_finalize.sh

	# Stop DCRAB processes	
	dcrab_stop_remote_processes 
}

dcrab_start_data_collection () {

        declare -a DCRAB_PIDs
        i=0
        for node in $DCRAB_NODES
        do
                # Create node folders
                mkdir -p $DCRAB_REPORT_DIR/data/$node
		
		# Calculate the second
		cont=$((DCRAB_TIME_HOWOFTEN * i))

                COMMAND="$DCRAB_BIN/scripts/dcrab_startDataCollection.sh $DCRAB_WORKDIR/$DCRAB_REPORT_DIR/aux/env.txt $i $cont $DCRAB_WORKDIR/$DCRAB_LOG_DIR/dcrab_$node.log & echo \$!"
		echo "COMMAND____= $COMMAND" 
                # Hay que poner la key, sino pide password
                DCRAB_PIDs[$i]=`ssh -n $node PATH=$PATH $COMMAND | tail -n 1 `

                echo "N: $node P:"${DCRAB_PIDs[$i]}", $DCRAB_TIME_HOWOFTEN" 

                # Next
                i=$((i+1))
        done
	
	# Save DCRAB_PID variable for future use
	dcrab_save_environment "DCRAB_PIDs" 
}

dcrab_determine_main_process () {

	DCRAB_MAIN_PID=0
		
	# CPU data
        cpu_data="["

	IFS=$'\n'
	for line in $(ps axo stat,euid,ruid,sess,ppid,pid,pcpu,comm | sed 's|\s\s*| |g' | grep "\s$DCRAB_USER_ID\s" | grep "Ss")
	do
		pid=$(echo "$line" | awk '{print $6}')
		pstree $pid | grep -q $DCRAB_JOB_ID
		[ "$?" -eq 0 ] && DCRAB_MAIN_PID=$pid && break
	done
	export DCRAB_MAIN_PID
	
	# Initialize data file
	for line in $(ps axo stat,euid,ruid,sess,ppid,pid,pcpu,comm | sed 's|\s\s*| |g' | grep "$DCRAB_MAIN_PID")
	do
	        pid=$(echo "$line" | awk '{print $6}')
		cpu=$(echo "$line" | awk '{print $7}')
                commandName=$(echo "$line" | awk '{print $8}')
		echo "$pid $commandName $cpu" >> $1

		# CPU data
                cpu_data="$cpu_data $cpu,"
	done
}

dcrab_update_data () {

	# CPU data
	cpu_data="["

	updates=0
	declare -a upd_proc_name
	IFS=$'\n'
        for line in $(ps axo stat,euid,ruid,sess,ppid,pid,pcpu,comm | sed 's|\s\s*| |g' | grep "$DCRAB_MAIN_PID")
        do
                pid=$(echo "$line" | awk '{print $6}')
		cpu=$(echo "$line" | awk '{print $7}')
		commandName=$(echo "$line" | awk '{print $8}')
		
		cat $1 | grep "^$pid $commandName"
		if [ "$?" -eq 0 ]; then
			sed 's/\('"$pid $name"'.*\)/\1 '"$cpu"'/' $1 
		else
			echo "^$pid $commandName $cpu" >> $1
			upd_proc_name[$updates]=$commandName
			updates=$((updates + 1))
		fi
	
		# CPU data
		cpu_data="$cpu_data $cpu,"
		

        done
} 

dcrab_init_variables () {

	export DCRAB_REPORT_DIR=dcrab_report_$DCRAB_JOB_ID
        export DCRAB_LOG_DIR=$DCRAB_REPORT_DIR/log
        export DCRAB_MAIN_JOB_PID=$PPID
	export DCRAB_USER_ID=`id -u $USER`
}


