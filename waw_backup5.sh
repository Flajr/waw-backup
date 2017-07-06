#!/usr/bin/env bash
#waw-backup
if [[ $(id -u) -eq 0 ]]; then
	printf "%s\n" "At this state of program, DO NOT RUN AS ROOT!"
	exit
fi

waw_backup_version="5.0.0"

function usage()
{
	printf "%s\n" "$0 version $waw_backup_version"
	printf "\n"
	printf "%s\n" "Usage: $0 [ARGUMENTS]"
	printf "%s\n" "       -b   | proceed backup"
	printf "%s\n" "       -c   | configure entries in $what and $where files"
	printf "%s\n" "       -m   | try create nonexisting folders (use with -t or -b)"
	printf "%s\n" "       -p   | prompt if you want to copy specified path"
	printf "%s\n" "       -s   | show what and where files"
	printf "%s\n" "       -t   | test files and folders, emulated backup"
	printf "\n"
	printf "%s\n" "what = What to backup; where = Where to backup"
	printf "%s\n" "Example: waw-backup -ty #test files and folders and create unexist (where) dirs"
	printf "%s\n" "         waw-backup -by #proceed backup and create where dirs, if don't exist"
	exit
}

#default configuration
function default_config()
{
	what="what.txt" #what to backup, add paths to files or folders you want to backup
	where="where.txt" #where save backups, one or more paths

	if [[ ! -e $what ]]; then
		touch $what
		printf "%s\n" "Dumped $what !"
	fi

	if [[ ! -e $where ]]; then
		touch $where
		printf "%s\n" "Dumped $where !"
	fi
}

#add entries to what and where files
function config()
{
		printf "%s\n" "Path to file/folder you want to backup (no input = continue)"
		what_entry="proceed"
		while read line; do
			if [[ -z $line ]]; then
				continue
			else
				printf "%s\n" "WHAT > $line"
			fi
		done < <(cat $what |awk '{print $1}')
		until [[ -z $what_entry ]]; do
			read -e -p "WHAT > " what_entry
				if [[ -n $what_entry ]]; then
					printf "%s\n" $what_entry >> $what
				fi

		done

		printf "%s" "\033[F\033[K"
		printf "\n"
		printf "%s\n" "Path to folder, where you want to create your backups (no input = continue)"
		where_entry="proceed"
		while read line; do
			if [[ -z $line ]]; then
				continue
			else
				printf "%s\n" "WHERE > $line"
			fi
		done< <(cat $where |awk '{print $1}')
		until [[ -z $where_entry ]]; do
			read -e -p "WHERE > " where_entry
				if [[ -n $where_entry ]]; then
					printf "%s\n" $where_entry >> $where
				fi
		done

		printf "%s" "\033[F\033[K"
		exit
}

function copy_dir()
{
	local var
	printf "%s" "$printf_var"
	if [[ $simulation -eq 1 ]]; then
		printf "\n"
	else
		if [[ $prompt_copy -eq 1 ]]; then
			read -p " Copy? (Yy/Nn)" var
			if [[ $var =~ Y|y ]]; then
				printf "%s" "\033[F\033[K$printf_var"
			elif [[ $var =~ N|n ]]; then
				printf "%s" "\033[F\033[K$printf_var\n"
				return 0
			fi
		fi

		printf " [COPYING]"
		cp -R -- "$what_read" "$where_read" 2>> log_file.txt
		local exit_status=$?

			if [[ $exit_status -eq 0 ]]; then
				printf "%s\n" " [OK]"
			else
				printf "%s\n" " [ERROR] [$exit_status]"
			fi
	fi
}

function copy_file()
{
	local var
	printf "%s" "$printf_var"
	if [[ $simulation -eq 1 ]]; then
		printf "\n"
	else
		if [[ $prompt_copy -eq 1 ]]; then
			read -p " Copy? (Yy/Nn)" var
			if [[ $var =~ Y|y ]]; then
				printf "%s" "\033[F\033[K$printf_var"
			elif [[ $var =~ N|n ]]; then
				printf "%s" "\033[F\033[K$printf_var\n"
				return 0
			fi
		fi

		printf "%s" " [COPYING]"
		cp -- "$what_read" "$where_read" 2>> log_file.txt
		local exit_status=$?

			if [[ $exit_status -eq 0 ]]; then
				printf "%s\n" " [OK]"
			else
				printf "%s\n" " [ERROR] [$exit_status]"
			fi
	fi
}

function show_waw()
{
	printf "%s\n" "what to backup in $what :"
	printf "\n"
	while read LINE; do
		if [[ -n $LINE ]]; then
			printf "%s\n" "$LINE"
		fi
	done < <(cat $what |awk '{print $1}')
	printf "\n"
	printf "%s\n" "where to backup in $where :"
	printf "\n"
	while read LINE; do
		if [[ -n $LINE ]]; then
			printf "%s\n" "$LINE"
		fi
	done < <(cat $where |awk '{print $1}')
	exit
}

function backup()
{
	local prompt until_loop_where="yes" until_loop


	if [[ ! -r $what ]]; then
		printf "%s\n" "No $what file found, or is unreadable"
		exit 1 #no file found, or unreadable

	elif [[ -z $(cat $what) ]]; then
		printf "%s\n" "No paths defined in $what file"
		exit 2 #no paths specified
	fi

	if [[ ! -r $where ]]; then
		printf "%s\n" "No $where file found, or is unreadable"
		printf "%s\n" "Will use default ~/waw-backup-d"
		printf "%s\n" ~/"waw-backup-d" > /tmp/temp-where-file.txt #use file because of while reading from file
		where="/tmp/temp-where-file.txt"

	elif [[ -z $(cat $where) ]]; then
		printf "%s\n" "No paths defined in $where file"
		printf "%s\n" "Will use default ~/waw-backup-d"
		printf "%s\n" ~/"waw-backup-d" > /tmp/temp-where-file.txt #use file because of while reading from file
		where="/tmp/temp-where-file.txt"
	fi

	until [[ $until_loop == "no" ]]; do
		if [[ $simulation -eq 1 ]]; then
			printf "%s\n" "Just Simulation"
			prompt="y"
		else
			read -p "Are you sure to proceed backup? Try argument -t first. (Yy/Nn) : " prompt
		fi


			if [[ $prompt =~ Y|y ]]; then
				if [[ -s log_file.txt ]]; then
					cat /dev/null > log_file.txt
				fi

				count=0
				for LINE in $(cat $where |awk '{print $1}'); do
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
				for LINE in $(cat $what |awk '{print $1}'); do
				if [[ -z $LINE ]]; then
					continue

				else
				printf "\n"
				what_read="$LINE"
				where_printout="yes"
				copy=

					if [[ -e $what_read ]]; then
					printf "%s" "$what_read [WHAT]"
						if [[ -d $what_read ]]; then
							printf "%s\n" " [DIR]"
							copy="dir"
						elif [[ -L $what_read ]]; then
							printf "%s\n" " [LINK]"
							copy="file"
						elif [[ -r $what_read ]]; then
							printf "%s\n" " [FILE]"
							copy="file"
						else
							printf "%s\n" "Unknown file/folder!"
							where_printout="no"
						fi

					else
						printf "%s\n" "$what_read doesn't exist! [WHAT]"
						where_printout="no"
					fi

					if [[ $where_printout == "yes" ]]; then

						for i in $(seq 0 $count); do
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
										printf "%s\n" "$where_read [WHERE] is not folder"
									;;
									3)
										printf "%s\n" "$where_read [WHERE] can't be create"
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
										printf "%s\n" "$where_read [WHERE] wasn't created (use -y)"
									;;
									*)
										printf "%s\n" "${where_read_status[$i]} [WHERE] [ERROR]"
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
				printf "\n%s\n" "Reported errors:"
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
			printf "%s\n" "INVALID OPTION: $OPTARG"
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
