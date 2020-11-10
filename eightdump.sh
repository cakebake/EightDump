#!/bin/sh

[ -z "$1" ] && echo "Please give me an absolute path to the configuration file (Example: /path/to/.env)." && exit 1
[ ! -f "$1" ] && echo "Configuration file '$1' does not exist." && exit 1 || config="$1"

set -u
code=0

user=$(grep "^BACKUP_USER=" "$config" | cut -f 2 -d '=')
[ -z "$user" ] && echo "Could not find variable 'BACKUP_USER' in configuration file '$config'." && code=1
pass=$(grep "^BACKUP_PASSWORD=" "$config" | cut -f 2 -d '=')
[ -z "$pass" ] && echo "Could not find variable 'BACKUP_PASSWORD' in configuration file '$config'." && code=1
host=$(grep "^BACKUP_HOST=" "$config" | cut -f 2 -d '=')
[ -z "$host" ] && echo "Could not find variable 'BACKUP_HOST' in configuration file '$config'." && code=1
db=$(grep "^BACKUP_DATABASE=" "$config" | cut -f 2 -d '=')
[ -z "$db" ] && echo "Could not find variable 'BACKUP_DATABASE' in configuration file '$config'." && code=1
dest=$(grep "^BACKUP_DESTINATION_DIR=" "$config" | cut -f 2 -d '=')
[ -z "$dest" ] && echo "Could not find variable 'BACKUP_DESTINATION_DIR' in configuration file '$config'." && code=1
keep=$(grep "^BACKUP_KEEP_MINUTES=" "$config" | cut -f 2 -d '=')
[ -z "$keep" ] && echo "Could not find variable 'BACKUP_KEEP_MINUTES' in configuration file '$config'." && code=1

[ $code -gt 0 ] && exit $code

datetime=$(date +%Y-%m-%d-%H-%M-%S)
dump="$dest/$db.$datetime.sql.gz"
log="$dest/.log"

mkdir -p "$dest"
find "$dest" -type f -not -path '*/\.*' -mmin "$keep" -delete
mysqldump -u"$user" -p"$pass" -h"$host" "$db" | gzip -9 > "$dump"
mysqlcheck -u"$user" -p"$pass" -h"$host" --check --force --auto-repair --databases "$db"
mysqlcheck -u"$user" -p"$pass" -h"$host" --optimize --force --databases "$db"

if [ -f "$dump" ]
then
  echo "$datetime [success] $db" >> "$log"
  exit 0
else
  echo "$datetime [failure] $db" >> "$log"
  exit 1
fi
