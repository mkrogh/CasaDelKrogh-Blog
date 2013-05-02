#!/bin/sh

# usage:
#   today
# get today formatted as e.g: 2012-03-23
function today() {
  date +"%Y-%m-%d" 
}

# usage:
#   today
# get today formatted a: 2012-03-27 22:15
function timestamp() {
  date +"%Y-%m-%d %H:%M" 
}

# usage:
#   backup_dir directory
# ensures that the given directory exists and sets it as target for backups
function backup_dir(){
  echo "Backup directory $1"
  path exists $1 || path create $1
  path enter $1
}


# usage:
#   dump_mysql [db_name] [mysql_opts] [backup_file]
# db_name defaults to $NAME
# db_params defaults to '-ubackup'
# backup_file defaults to '$db_name'_db-
function dump_mysql() {
  local db_name=${1:-$NAME}
  local mysql_opts=${2:--ubackup} 
  local backup_file=${3:-$db_name\_db-}
  local file="$backup_file$(today).sql.gz"

  log step "Dumping database to $file"
  mysqldump $mysql_opts $db_name | gzip -c > $file
  if file exists $file
  then
    log step success
  else
    log step fail
  fi
}

# usage:
#   rotate [file] [amount]
# file defaults to $NAME_, all files are globbed with * 
# amount defaults to keep 5 files
function rotate(){
  local amount=${2:-5}
  local file=${1:-$NAME\_}
  echo "Cleaning: keeping $amount backups"
  ls -1v $file* 2>/dev/null | head -n -$amount | while read file
  do
    log step "removing $file" \
      rm -rf $file
  done
}

# usage:
#   rsync src [dest] [rsync_param]
# dest defaults to current dir ($backup_dir) 
function rsync_it(){
  local src=$1
  local dest=${2:-./}
  echo "$(timestamp) Rsync from $src to $dest"
  rsync -az -e ssh  $src $dest
}
