<h1 align="center">
make-backup
</h1>

It does exactly what you would expect: it makes backups. It's basically a
wrapper for `tar` and `pigz` with a nice logger and some other neat features.

### Examples
Make a backup of current users' home directory:
```
make-backup
```

Make a backup of current users' home directory, put it in the target drive
and send a POST notification when finished:
```
make-backup o=/mnt/backup_drive p="example.com/topic"
```
