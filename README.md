# EightDump

Scheduled MySQL dump &amp; check.

Features

- [x] Creates GZip MySQL backups
- [x] Optimizes/Repairs MySQL database
- [x] Deletes old backups after a specified time
- [x] Usable with cron, but also manually
- [x] Environment file support
- [ ] Global environment variables support
- [ ] Supports MariaDb
- [x] Logging

## Installation

```bash
mkdir -p ~/bin && \
wget https://raw.githubusercontent.com/cakebake/EightDump/main/eightdump.sh -O ~/bin/eightdump && \
chmod +x ~/bin/eightdump
```

> Check if `~/bin` is in the global $PATH or add it. Example: `echo "export PATH=$PATH:$HOME/bin" >> ~/.bashrc`

## Configuration

Create or edit a configuration file with following variables.

```bash
BACKUP_USER=user
BACKUP_PASSWORD=password
BACKUP_HOST=localhost
BACKUP_PORT=3306
BACKUP_DATABASE=name
BACKUP_DESTINATION_DIR=/var/www/html/project/backup
BACKUP_KEEP_MINUTES=10080
```

## Usage

CLI

```bash
eightdump /path/to/.env
```

Cron

```cron
# every day 04h00
0 4 * * * /home/name/bin/eightdump /path/to/.env >/dev/null 2>&1
# every 6h
0 */6 * * * /home/name/bin/eightdump /path/to/.env >/dev/null 2>&1
```
