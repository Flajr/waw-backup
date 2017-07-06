# waw-backup 5.0.0
What and Where Backup. Easy as possible backup, with file what.txt (what to backup) and where.txt (where to backup).

what.txt mean paths to directories/files what you want to backup.
where.txt mean paths to directories where paths from what.txt will be copied.

# Usage and how to
```bash
waw_backup5 [ARGUMENTS]
       -b   | proceed backup
       -c   | configure entries in $what and $where files
       -m   | try create nonexisting folders (use with -t or -b)
       -p   | prompt if you want to copy specified path
       -s   | show what and where files
       -t   | test files and folders, emulated backup

what = What to backup; where = Where to backup
Example: waw-backup -ty #test files and folders and create unexist (where) dirs
	     waw-backup -by #proceed backup and create where dirs, if don't exist
```
```bash
sudo chmod +x waw-backup.sh
./waw-backup.sh
```
After this command program dumped 2 files in directory (what.txt and where.txt).
Now you can simple add paths (preferable FULL PATHS) in that files.

Then try use argument -t to see what will be done.
```bash
./waw-backup.sh -t
```
If you want to proceed backup use argument -b
```bash
./waw-backup.sh -b
```

# Simulation
```bash
marek@1015CX:~/Sync/waw-backup$ ./waw-backup.sh -t
Just Simulation

/home/marek/git repos [WHAT] [DIR]
/home/marek/backup_folder [WHERE]
/home/marek/backup_folder2 [WHERE] wasn't created (use -y)
/home/marek/backup_folder 3 [WHERE] wasn't created (use -y)

/home/marek/bookmarks.html [WHAT] [FILE]
/home/marek/backup_folder [WHERE]
/home/marek/backup_folder2 [WHERE] wasn't created (use -y)
/home/marek/backup_folder 3 [WHERE] wasn't created (use -y)

/home/marek/something.txt [WHAT] [LINK]
/home/marek/backup_folder [WHERE]
/home/marek/backup_folder2 [WHERE] wasn't created (use -y)
/home/marek/backup_folder 3 [WHERE] wasn't created (use -y)
```

# Backup
```bash
marek@1015CX:~/Sync/waw-backup$ ./waw-backup.sh -by #backup and create folders
Are you sure to proceed backup? Try argument -t first. (Yy/Nn) : y

/home/marek/git repos [WHAT] [DIR]
/home/marek/backup_folder [WHERE] [COPYING] [OK]
/home/marek/backup_folder2 [WHERE] [CREATED] [COPYING] [OK]
/home/marek/backup_folder 3 [WHERE] [CREATED] [COPYING] [OK]

/home/marek/bookmarks.html [WHAT] [FILE]
/home/marek/backup_folder [WHERE] [COPYING] [OK]
/home/marek/backup_folder2 [WHERE] [CREATED] [COPYING] [OK]
/home/marek/backup_folder 3 [WHERE] [CREATED] [COPYING] [OK]

/home/marek/something.txt [WHAT] [LINK]
/home/marek/backup_folder [WHERE] [COPYING] [OK]
/home/marek/backup_folder2 [WHERE] [CREATED] [COPYING] [OK]
/home/marek/backup_folder 3 [WHERE] [CREATED] [COPYING] [OK]
```
# Configure
```bash
marek@1015CX:~/Sync/waw-backup$ ./waw-backup.sh -c
Path to file/folder you want to backup (no input = continue)
WHAT > /home/marek/git repos
WHAT > /home/marek/bookmarks.html
WHAT > /home/marek/something.txt
WHAT > /home/marek/Sync/waw-backup

Path to folder, where you want to create your backups (no input = continue)
WHERE > /home/marek/backup_folder
WHERE > /home/marek/backup_folder2
WHERE > /home/marek/backup_folder 3
```
