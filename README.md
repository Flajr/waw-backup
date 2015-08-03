# waw-backup 1.0.0
What and Where Backup. Easy as possible backup, with file what.txt (what to backup) and where.txt (where to backup).

what.txt mean paths to directories/files what you want to backup.
where.txt mean paths to directories where paths from what.txt will be copied.

# How to?!
```bash
sudo chmod +x waw-backup.sh
./waw-backup.sh
```
After this command program dumped 2 files in his directory (what.txt and where.txt).
Now you can simple add paths (preferable FULL PATHS) in that files.

Then try use argument -t to see what will be done. 
```bash
./waw-backup.sh -t
```
If you want to proceed backup use argument -b
```bash
./waw-backup.sh -b
```

This code is first idea and that is why version is 0.0.1

# Simulation
```bash
Simulation Backup will proceed!

WHAT 1. dir 
/home/test/Documents/ #from what.txt file, dir mean directory
WHERE
/home/test/Sync/ #from where.txt file
/home/test/Desktop/
/home/test/Documents/
/folder1 doesn't exist!
/folder two doesn't exist!
/home/test/tput_test.sh is not folder #not folder so you can't backup there

WHAT 2. file #file mean regular file
/home/test/Sync/Sync/pineapples_final2.png
WHERE
/home/test/Sync/
/home/test/Desktop/
/home/test/Documents/
/test space doesn't exist!
/something doesn't exist!
/home/test/tput_test.sh is not folder

WHAT 3. /home/test/test_folder/something doesn't exist!

WHAT 4. /home/find_me doesn't exist!
```

# Backup
```bash
Are you sure to proceed backup? Try argument -t first. (Yy/Nn) : y
Backup will proceed!

WHAT 1. file
/home/test/dnt-ver.9/additional_functions.sh
WHERE
/home/test_folder/test doesn't exist!
/home/test/test_two > file copied!

WHAT 2. dir
/home/test/dnt-ver.9/dialog_tcpdump-rpm
WHERE
/home/test_folder/test doesn't exist!
/home/test/test_two > dir copied!
```
