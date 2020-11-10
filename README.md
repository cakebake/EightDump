# EightDump

Scheduled MySQL dump &amp; check.

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
BACKUP_KEEP_MINUTES=30
```

## Usage

```bash
eightdump /path/to/.env
```
