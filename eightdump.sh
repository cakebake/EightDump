#!/bin/sh

[ -z "$1" ] && echo "Please give me an absolute path to the configuration file (Example: /path/to/.env)." && exit 1
[ ! -f "$1" ] && echo "Configuration file '$1' does not exist." && exit 1 || config="$1"

set -u
code=0

user=$(grep "^BACKUP_USER=" "$config" 2> /dev/null | cut -f 2 -d '=')
[ -z "$user" ] && echo "Could not find variable 'BACKUP_USER' in configuration file '$config'." && code=1
pass=$(grep "^BACKUP_PASSWORD=" "$config" 2> /dev/null | cut -f 2 -d '=')
[ -z "$pass" ] && echo "Could not find variable 'BACKUP_PASSWORD' in configuration file '$config'." && code=1
host=$(grep "^BACKUP_HOST=" "$config" 2> /dev/null | cut -f 2 -d '=')
[ -z "$host" ] && echo "Could not find variable 'BACKUP_HOST' in configuration file '$config'." && code=1
port=$(grep "^BACKUP_PORT=" "$config" 2> /dev/null | cut -f 2 -d '=')
[ -z "$port" ] && echo "Could not find variable 'BACKUP_PORT' in configuration file '$config'." && code=1
db=$(grep "^BACKUP_DATABASE=" "$config" 2> /dev/null | cut -f 2 -d '=')
[ -z "$db" ] && echo "Could not find variable 'BACKUP_DATABASE' in configuration file '$config'." && code=1
dest=$(grep "^BACKUP_DESTINATION_DIR=" "$config" 2> /dev/null | cut -f 2 -d '=')
[ -z "$dest" ] && echo "Could not find variable 'BACKUP_DESTINATION_DIR' in configuration file '$config'." && code=1
keep=$(grep "^BACKUP_KEEP_MINUTES=" "$config" 2> /dev/null | cut -f 2 -d '=')
[ -z "$keep" ] && echo "Could not find variable 'BACKUP_KEEP_MINUTES' in configuration file '$config'." && code=1

[ $code -gt 0 ] && exit $code

datetime=$(date +%Y-%m-%d-%H-%M-%S)
dump="$dest/$db.$datetime.sql.gz"
log="$dest/.log"

mkdir -p "$dest"
find "$dest" -type f -not -path '*/\.*' -mmin "+$keep" -delete

if [ -x "$(command -v mysqldump)" ]; then
  mysqldumpExe=mysqldump
elif [ -x "$(command -v /usr/bin/mysqldump)" ]; then
  mysqldumpExe=/usr/bin/mysqldump
elif [ -x "$(command -v /usr/local/mysql/bin/mysqldump)" ]; then
  mysqldumpExe=/usr/local/mysql/bin/mysqldump
elif [ -x "$(command -v /usr/local/mysql5/bin/mysqldump)" ]; then
  mysqldumpExe=/usr/local/mysql5/bin/mysqldump
fi
if [ ! -z "$mysqldumpExe" ]; then
  echo "Found $mysqldumpExe executable."
  if [ -x "$(command -v gzip)" ]; then
    echo "Found gzip executable."
    "$mysqldumpExe" --no-tablespaces -u"$user" -p"$pass" -h"$host" -P"$port" "$db" | gzip -9 > "$dump"
  else
    "$mysqldumpExe" --no-tablespaces -u"$user" -p"$pass" -h"$host" -P"$port" "$db" > "$dump"
  fi
else
  echo "Could not find mysqldump executable."
fi

if [ -x "$(command -v mysqlcheck)" ]; then
  mysqlcheckExe=mysqlcheck
elif [ -x "$(command -v /usr/bin/mysqlcheck)" ]; then
  mysqlcheckExe=/usr/bin/mysqlcheck
elif [ -x "$(command -v /usr/local/mysql/bin/mysqlcheck)" ]; then
  mysqlcheckExe=/usr/local/mysql/bin/mysqlcheck
elif [ -x "$(command -v /usr/local/mysql5/bin/mysqlcheck)" ]; then
  mysqlcheckExe=/usr/local/mysql5/bin/mysqlcheck
fi
if [ ! -z "$mysqlcheckExe" ]; then
  echo "Found $mysqlcheckExe executable."
  "$mysqlcheckExe" -u"$user" -p"$pass" -h"$host" -P"$port" --check --force --auto-repair --databases "$db"
  "$mysqlcheckExe" -u"$user" -p"$pass" -h"$host" -P"$port" --optimize --force --databases "$db"
else
  echo "Could not find mysqlcheck executable."
fi

size=$(du -hs "$dest")
who=$(whoami)
if [ -f "$dump" ]; then
  echo "$datetime	[success][$who]	$db; All backups: $size" >> "$log"
  exit 0
else
  echo "$datetime	[failure][$who]	$db; All backups: $size" >> "$log"
  exit 1
fi
