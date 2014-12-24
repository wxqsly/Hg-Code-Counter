#! /usr/bin/bash
#Author: Nicolas.Wang
#Version: 1.0.0

printf "\nWelcome to this simple tool: $current_dir\n"
printf "\nThis execution will pull and update your local code repository,\n"
printf "\nplease be sure that you already commited or processed your codes properly.\n\n"

read -p "Are you sure to continue? [Press 'y' to continue, others to abort]: " select
#read select

if [ -n "$select"  -a  "$select" = "y" ];
	then
		#Get original dir where this shell script exists
		current_dir=`pwd`
		printf "\nOriginal dir: $current_dir\n"

		#Get the working directory from property files, trim the blank characters with gensub function
		working_dir=`cat config.properties |grep webclaim_root_path|awk -F'=' '{print $2}' | awk '{ result=gensub(/ /, "" ,1); print result }'`
		#working_dir=`cat config.properties |grep webclaim_root_path|awk -F'=' '{print $2}'`

		#Trim the blank characters with gensub function
		count_from=`cat config.properties |grep count_from_time|awk -F'=' '{print $2}' | awk '{ result=gensub(/ /, "" ,1); print result }'`

		#Trim the blank characters with gensub function
		count_end=`cat config.properties |grep count_end_time|awk -F'=' '{print $2}' | awk '{ result=gensub(/ /, "" ,1); print result }'`

		printf "\nCount duration will be from $count_from to $count_end\n"

		#Get the user list from property files
		users=`cat config.properties |grep users|awk -F'=' '{print $2}'`

		#Save original separators in a variable
		OLD_IFS="$IFS"

		#Set current seprator to ',' for array
		IFS=","

		printf "\nChanged to working dir: "$working_dir"\n"
		cd "$working_dir"

		#Split each user individually
		#user_array=($(echo $users |tr ',' ' '))
		user_array=($users)

		length=${#user_array[@]}
		#echo ${length}
		printf "\nStart to count the lines for '$users', ${length} users will be counted.\n"


		printf "Starting to pull revisions from server repository\n"
		#pull the newest revisions
		hg pull

		printf "\nUpdating the revisions into local repository...\n"
		#update the revisions to local repository
		hg update

		#current time
		current=`date "+%Y-%m-%d_%H-%M-%S"`

		#Create dir to store the count files
		report_dir="$current_dir/count_$current"

		mkdir "$report_dir"
		printf "\nCount dir $report_dir created successfully.\n"

		report_file="$report_dir/count_report.log"	
		
		#All added lines for all users
		total_add=0
		
		#All deleted lines for all users
		total_del=0
		
		for ((i=0; i<$length; i++))
		do
				
				#echo ${user_array[$i]}
				#Trim the blank characters for each user
				user=`echo ${user_array[$i]} | awk '{ result=gensub(/ /, "" ,1); print result }'`
				#echo $user
				
				#For each user, get the files changed in specified duration, and put into individual file
				printf "\nFetching changed files history for ${user}, "
				
				raw_log="$report_dir/user_${i}_raw.log"
				#user_log=count_user_$i.log
				
				#Ignore the merged revisions with -M para
				hg log --stat -d "$count_from to $count_end" -u "${user}" -M > "$raw_log"
				revisions=`grep "changeset:" "$raw_log" | awk -F ':' '{print $2}' | awk '{ result=gensub(/ +/, "" ,1); print result}' | xargs echo`
				printf "Revisions to be counted:\n$revisions\n"
				
				proc_log="$report_dir/user_${i}_proc.log"
				
				#Set current seprator to ' ' for array
				IFS=" "
				
				for revision in $revisions
				do
					#Use hg diff --stat -b to ignore the lines with blanks-changed only
					#printf "hg diff --stat -c $revision -b"
					hg diff --stat -c $revision -b >> "$proc_log"
					#grep "changeset:" "$raw_log" | awk -F ':' '{print $2}' | awk '{ result=gensub(/ +/, "" ,1); print result}' |xargs -i hg diff --stat -c {} -b > "$proc_log"
				done
				
				#Set current seprator to ',' for array
				IFS=","
				
				#echo Changed files history for ${user} generated:
				#echo $i
				if [ $i -eq 0 ]; 
					then
						printf "%-20s|%-20s|%-20s|%-20s\n" "User" "Added lines" "Deleted lines" "Total changed lines"  > "$report_file"
				fi
				 
				#Added lines for current user
				added=0
				if [ -e $proc_log ]
					then
						added=`cat "$proc_log" |grep 'files changed'| awk -F ',' '{print $2}'|awk '{sum +=$1} END {print sum}'`
				fi
				#added=`cat "$proc_log" |grep 'files changed'| awk -F ',' '{print $2}'|awk '{sum +=$1} END {print sum}'`
				if [[ ! $added ]];
					then 
					added=0
				fi
				total_add=`expr $added + $total_add`
				
				deleted=0
				if [ -e $proc_log ]
					then
						deleted=`cat "$proc_log" |grep 'files changed'| awk -F ',' '{print $3}'|awk '{sum +=$1} END {print sum}'`
				fi
				#Deleted lines for current user
				#deleted=`cat "$proc_log" |grep 'files changed'| awk -F ',' '{print $3}'|awk '{sum +=$1} END {print sum}'`
				if [[ ! $deleted ]];
					then 
					deleted=0
				fi
				
				total_del=`expr $deleted + $total_del`
				
				printf "%-20s|%-20s|%-20s|%-20s\n" "${user}" "$added" "$deleted" "`expr $added + $deleted`" >> "$report_file"
				printf "\n" >> "$report_file"
		done

		printf "%-20s|%-20s|%-20s|%-20s\n" "Total" "$total_add" "$total_del" "`expr $total_add + $total_del`" >> "$report_file"
		printf "\nFetching files finished, start to generate report: \n"
		printf "\n"
		cat "$report_file"

		#Restore the original separators
		IFS="$OLD_IFS"

		printf "\nChanged back to original dir: $current_dir\n"
		cd "$current_dir"

		printf "\nGenerated report can be found in file: $report_file.\n"
		
else
    printf "\nPlease execute this tool again when you are ready.\n"
fi