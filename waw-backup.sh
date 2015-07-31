#!/bin/bash
#waw-backup
waw_backup_version="0.0.1"

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
		until [[ -z $what_entry ]]; do	
			read -e -p "what > " what_entry
				if [[ -n $what_entry ]]; then
					echo $what_entry >> $what
				
				fi
		
		done
		
		echo -ne "\033[F\033[K"
		echo
		echo "Path to folder, where you want to create your backups (no input = continue)"
		where_entry="proceed"
		until [[ -z $where_entry ]]; do		
			read -e -p "where > " where_entry
				if [[ -n $where_entry ]]; then
					echo $where_entry >> $where
				
				fi
		
		done

		echo -ne "\033[F\033[K"
	
}

function copy_dir()
{
	if [[ $simulation == "yes" ]]; then
		echo
	
	else	
		cp -R "$what_read" "$where_read"
		if [[ $? -eq 0 ]]; then
			echo " > dir copied!"
		else
			echo " > ERROR!"
		fi
	
	fi
}

function copy_file()
{
	if [[ $simulation == "yes" ]]; then
		echo
	
	else
		cp "$what_read" "$where_read"
		if [[ $? -eq 0 ]]; then
			echo " > file copied!"
		else
			echo " > ERROR!"
		
		fi
	fi
}

function backup()
{
if [[ ! -r $what ]]; then
				echo "What to backup in file $what - No file found, or is unreadable."
				exit

			elif [[ -z $(cat $what) ]]; then
				echo "What to backup in file $what - No path specified, nothing to backup."
				exit


			fi

			if [[ ! -r $where ]]; then
				echo "Where save backup in file $where - No file found, or is unreadable."
				exit

			elif [[ -z $(cat $where) ]]; then
				echo "Where save backup in file $where - No path specified, don't know where save backup."
				exit

			fi

				until [[ $until_loop == "no" ]]; do
					if [[ $simulation == "yes" ]]; then
						echo -n "Simulation "
						prompt="y"

					else
						read -p "Are you sure to proceed backup? Try argument -t first. (Yy/Nn) : " prompt
						
					fi

						
						if [[ $prompt =~ Y|y ]]; then
							echo "Backup will proceed!"
							count=0
								while read LINE; do
								if [[ $LINE != "" ]]; then
								
								((count++))
								echo
								echo -n "$count. "
									what_read=$LINE
									where_printout="yes"	
									copy=

										if [[ -e $what_read ]]; then
											if [[ -d $what_read ]]; then
												echo "copy (d) $what_read to :"
												copy="dir"

											elif [[ -r $what_read ]]; then
												echo "copy (-) $what_read to :"
												copy="file"

											elif [[ -L $what_read ]]; then
												echo "copy (l) $what_read to :"
												copy="file"


											else
												echo "Unknown file/folder!"
												where_printout="no"

											fi
										
										else
											echo "$what_read doesn't exist!"
											where_printout="no"

										fi

									if [[ $where_printout == "yes" ]]; then
									echo
										
									while read LINE; do
									if [[ $LINE != "" ]]; then
										where_read=$LINE
											if [[ -e $where_read ]]; then
												if [[ -d $where_read ]]; then
													echo -n "$where_read"
													if [[ $copy == "dir" ]]; then
														copy_dir
													
													else
														copy_file
													
													fi

												else
													echo "$where_read is not folder"

												fi

											else
												echo "$where_read doesn't exist!"
												
											fi
									fi
									done < <(cat $where)
									
									fi
								
								fi
								done < <(cat $what)

							until_loop="no"
						elif [[ $prompt =~ N|n ]]; then
							echo "Backup won't proceed!"
							until_loop="no"
						else
							until_loop="yes"
						
						
						fi
				
				done
}

#SCRIPT START############################################################
#if config file exist load it else use default options
if [[ -e waw_backup.conf ]]; then
	. waw_backup.conf

else
	default_config

fi

####################################
#show program usage if no argument given
if [[ -z $1 ]]; then
	usage="show"

else
	usage="hide_usage"

fi

until [[ -z "$1" && $usage == "hide_usage" ]]; do
	case $1 in
		-c) #run config-menu
			config
			exit
			;;

		-b) #just proceed backup
			backup
			exit		
			;;

		-s)
			echo "what to backup in $what :"
			echo
			while read LINE; do
				echo "     $LINE"
			done < <(cat $what)
			echo
			echo "where to backup in $where :"
			echo 
			while read LINE; do
				echo "     $LINE"
			done < <(cat $where)
			exit
			;;

		-t)
			simulation="yes"
			backup
			exit
			;;

		*)
			echo "waw-backup version $waw_backup_version"
			echo
			echo "Usage: Run with one argument only."
			echo "       -b    | proceed backup"
			echo "       -c    | configure entries in $what and $where files"
			echo "       -s    | show what and where files"
			echo "       -t    | test files and folders, emulated backup"
			echo "what = What to backup; where = Where to backup"
			usage="hide_usage"
			exit
			;;

	
	esac
	 
	shift

done