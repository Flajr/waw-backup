#!/bin/bash
#waw-backup
if [[ $(id -u) -eq 0 ]]; then
	echo "At this state of program, DO NOT RUN AS ROOT!"
	exit
fi

waw_backup_version="5.0.0"

function usage()
{
	echo "$0 version $waw_backup_version"
	echo
	echo "Usage: $0 [ARGUMENTS]"
	echo "       -b   | proceed backup"
	echo "       -c   | configure entries in $what and $where files"
	echo "       -p   | prompt if you want to copy specified path"
	echo "       -s   | show what and where files"
	echo "       -t   | test files and folders, emulated backup"
	echo "       -m   | try create nonexisting folders (use with -t or -b)"
	echo
	echo "what = What to backup; where = Where to backup"
	echo "Example: waw-backup -ty #test files and folders and create unexist (where) dirs"
	echo "         waw-backup -by #proceed backup and create where dirs, if don't exist"
	exit
}

#default configuration
function default_config()
{
	what="what.txt" #what to backup, add paths to files or folders you want to backup
	where="where.txt" #where save backups, one or more paths

	if [[ ! -e $what ]]; then
		touch $what
		echo "Dumped $what !"
	fi

	if [[ ! -e $where ]]; then
		touch $where
		echo "Dumped $where !"
	fi
}

#add entries to what and where files
function config()
{ 
		echo "Path to file/folder you want to backup (no input = continue)"
		what_entry="proceed"
		while read line; do
			if [[ -z $line ]]; then
				continue
			else
				echo "WHAT > $line"
			fi
		done < <(cat $what |awk '{print $1}')
		until [[ -z $what_entry ]]; do	
			read -e -p "WHAT > " what_entry
				if [[ -n $what_entry ]]; then
					echo $what_entry >> $what
				fi
		
		done
		
		echo -ne "\033[F\033[K"
		echo
		echo "Path to folder, where you want to create your backups (no input = continue)"
		where_entry="proceed"
		while read line; do
			if [[ -z $line ]]; then
				continue
			else
				echo "WHERE > $line"
			fi
		done< <(cat $where |awk '{print $1}')
		until [[ -z $where_entry ]]; do		
			read -e -p "WHERE > " where_entry
				if [[ -n $where_entry ]]; then
					echo $where_entry >> $where
				fi
		done

		echo -ne "\033[F\033[K"
		exit
}

function copy_dir()
{
	local var
	printf "$printf_var"
	if [[ $simulation -eq 1 ]]; then
		echo
	else	
		if [[ $prompt_copy -eq 1 ]]; then
			read -p " Copy? (Yy/Nn)" var
			if [[ $var =~ Y|y ]]; then
				printf "\033[F\033[K$printf_var"
			elif [[ $var =~ N|n ]]; then
				printf "\033[F\033[K$printf_var\n"
				return 0
			fi
		fi

		printf " [COPYING]"
		cp -R -- "$what_read" "$where_read" 2>> log_file.txt
		local exit_status=$?
			
			if [[ $exit_status -eq 0 ]]; then
				printf " [OK]\n"
			else
				printf " [ERROR] [$exit_status]\n"
			fi
	fi
}

function copy_file()
{
	local var
	printf "$printf_var"
	if [[ $simulation -eq 1 ]]; then
		echo
	else
		if [[ $prompt_copy -eq 1 ]]; then
			read -p " Copy? (Yy/Nn)" var
			if [[ $var =~ Y|y ]]; then
				printf "\033[F\033[K$printf_var"
			elif [[ $var =~ N|n ]]; then
				printf "\033[F\033[K$printf_var\n"
				return 0
			fi
		fi
		
		printf " [COPYING]"
		cp -- "$what_read" "$where_read" 2>> log_file.txt
		local exit_status=$?
			
			if [[ $exit_status -eq 0 ]]; then
				printf " [OK]\n"
			else
				printf " [ERROR] [$exit_status]\n"
			fi
	fi
}

function show_waw()
{
	echo "what to backup in $what :"
	echo
	while read LINE; do
		if [[ -n $LINE ]]; then
			echo "$LINE"
		fi
	done < <(cat $what |awk '{print $1}')
	echo
	echo "where to backup in $where :"
	echo 
	while read LINE; do
		if [[ -n $LINE ]]; then
			echo "$LINE"
		fi
	done < <(cat $where |awk '{print $1}')
	exit
}

function backup()
{
	local prompt until_loop_where="yes" until_loop 


	if [[ ! -r $what ]]; then
		echo "No $what file found, or is unreadable"
		exit 1 #no file found, or unreadable

	elif [[ -z $(cat $what) ]]; then
		echo "No paths defined in $what file"
		exit 2 #no paths specified
	fi

	if [[ ! -r $where ]]; then
		echo "No $where file found, or is unreadable"
		echo "Will use default ~/waw-backup-d"
		echo ~/"waw-backup-d" > /tmp/temp-where-file.txt #use file because of while reading from file
		where="/tmp/temp-where-file.txt"

	elif [[ -z $(cat $where) ]]; then
		echo "No paths defined in $where file"
		echo "Will use default ~/waw-backup-d"
		echo ~/"waw-backup-d" > /tmp/temp-where-file.txt #use file because of while reading from file
		where="/tmp/temp-where-file.txt"
	fi

	until [[ $until_loop == "no" ]]; do
		if [[ $simulation -eq 1 ]]; then
			echo "Just Simulation"
			prompt="y"
		else
			read -p "Are you sure to proceed backup? Try argument -t first. (Yy/Nn) : " prompt
		fi

			
			if [[ $prompt =~ Y|y ]]; then
				if [[ -s log_file.txt ]]; then
					cat /dev/null > log_file.txt
				fi

				count=0
				for LINE in `cat $where |awk '{print $1}'`; do
				if [[ -z $LINE ]]; then
					continue

				else
					where_read="$LINE"
						if [[ -e $where_read ]]; then
							if [[ -d $where_read ]]; then
								where_read_status[$count]=1 #is dir
							else
								where_read_status[$count]=2 #is not dir
							fi

						where_read_var[$count]="$where_read"
						let count++

						else
							while [[ $until_loop_where == "yes" ]]; do
									if [[ $create_folder -eq 1 ]]; then
										mkdir "$where_read"
											if [[ $? -ne 0 ]]; then
												where_read_status[$count]=3 #can't create folder
											else
												where_read_status[$count]=4 #created folder
											fi

										until_loop_where="no"

									else
										where_read_status[$count]=5 #if doesn't exist, do not create
										until_loop_where="no"
									fi
							done

							where_read_var[$count]="$where_read"
							let count++
							until_loop_where="yes"
						fi
				fi
				done

				let count--
				for LINE in `cat $what |awk '{print $1}'`; do
				if [[ -z $LINE ]]; then
					continue

				else
				echo
				what_read="$LINE"
				where_printout="yes"	
				copy=

					if [[ -e $what_read ]]; then
					printf "$what_read [WHAT]"
						if [[ -d $what_read ]]; then
							printf " [DIR]\n"
							copy="dir"
						elif [[ -L $what_read ]]; then
							printf " [LINK]\n"
							copy="file"
						elif [[ -r $what_read ]]; then
							printf " [FILE]\n"
							copy="file"
						else
							echo "Unknown file/folder!"
							where_printout="no"
						fi
					
					else
						echo "$what_read doesn't exist! [WHAT]"
						where_printout="no"
					fi
					
					if [[ $where_printout == "yes" ]]; then
						
						for i in `seq 0 $count`; do
						where_read="${where_read_var[$i]}"
								case ${where_read_status[$i]} in
									
									1)
										printf_var="$where_read [WHERE]" #do not new line [COPYING
											if [[ $copy == "dir" ]]; then
												copy_dir
											
											else
												copy_file
											
											fi
									;;
									2)
										printf "$where_read [WHERE] is not folder\n"
									;;
									3)
										printf "$where_read [WHERE] can't be create\n"
									;;
									4)
										printf_var="$where_read [WHERE] [CREATED]"
											if [[ $copy == "dir" ]]; then
												copy_dir
											else
												copy_file
											fi
									;;
									5)
										printf "$where_read [WHERE] wasn't created (use -y)\n"
									;;
									*)
										printf "${where_read_status[$i]} [WHERE] [ERROR]\n"	
									;;
								esac
						done
					fi
				fi
				done

				until_loop="no"
			elif [[ $prompt =~ N|n ]]; then
				until_loop="no"
			else
				until_loop="yes"
			fi
	
			if [[ -s log_file.txt ]]; then
				printf "\nReported errors: \n"
				cat log_file.txt
			fi
	done
}

#SCRIPT START############################################################
default_config

####################################
#show program usage if no argument given
if [[ $# -eq 0 ]]; then
	usage
fi

while getopts :bcmstp opt; do
	case $opt in
		
		b) #just proceed backup
			backup_var=1
		;;
		
		c) #run config-menu
			config_var=1
		;;
		
		s)
			show_waw_var=1
		;;

		t)
			simulation=1
			backup_var=1
		;;
		
		p)
			prompt_copy=1
		;;

		m)
			create_folder=1
		;;

		*)
			echo "INVALID OPTION: $OPTARG"
			usage
		;;
	esac
done

if [[ $config_var -eq 1 ]]; then
	config
elif [[ $backup_var -eq 1 || $simulation ]]; then
	backup
elif [[ $show_waw_var -eq 1 ]]; then
	show_waw
fi