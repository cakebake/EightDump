# EightDump

Scheduled MySQL dump &amp; check.

Features

- [x] Creates GZip MySQL backups
- [x] Optimizes/Repairs MySQL database
- [x] Deletes old backups after a specified time
- [x] Usable with cron, but also manually
- [x] Environment file support
- [ ] Global environment variables support
- [x] Logging

## Installation

```bash
wget https://raw.githubusercontent.com/cakebake/EightDump/main/eightdump.sh -O eightdump && chmod +x eightdump
```

## Configuration

Create or edit a configuration file with following variables.

```bash
BACKUP_USER=user
BACKUP_PASSWORD=password
BACKUP_HOST=localhost
BACKUP_DATABASE=name
BACKUP_DESTINATION_DIR=/var/www/html/project/backup
BACKUP_KEEP_MINUTES=10080
```

## Usage

CLI

```bash
./eightdump /path/to/.env
```

Cron

```cron
# every day 04h00
0 4 * * * /path/to/eightdump /path/to/.env >/dev/null 2>&1
# every 6h
0 */6 * * * /path/to/eightdump /path/to/.env >/dev/null 2>&1
```
