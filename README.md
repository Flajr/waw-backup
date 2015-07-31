# waw-backup
What and Where Backup. Easy as possible backup, with file what.txt (what to backup) and where.txt (where to backup).

# How to?!
```bash
sudo chmod +x waw-backup.sh
./waw-backup.sh
```

After this command program dumped 2 files in his directory. (what.txt and where.txt)
Now you can simple add paths (preferable FULL PATHS) in that files.

what.txt mean paths to directories/files what you want to back up.
where.txt mean paths to directories where paths from what.txt will be copied.

Then try use argument -t to see what will be done. 
```bash
./waw-backup.sh -t
```
If you want to proceed backup use argument -b
```bash
./waw-backup.sh -b
```

This code is first idea and that is why version is 0.0.1
