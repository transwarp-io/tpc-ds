#!/bin/bash

echo "********************************************************************"
echo "*****  Tables stored as other file-format is implemented as:   *****"
echo "****  create table t stored as XXX as select * from TEXT_DB.t   ****"
echo "********************************************************************"

function usage {
  echo "Usage: $0 
  -s | --sourcedb, TEXT_DB
  -t | --targetdb, FORMAT_DB 
  -f | --format, TBL_FORMAT
  -c | --command, EXEC COMMAND, hive by default
  -d | --delete, DELETE_MODE, true or false
  -l | --location, LOCATION_HDFS of flat file, can not be empty when DELETE_MODE is true
  --help, show this help message."
}

while [ $# -gt 0 ]; do
  case "$1" in
    -s | --sourcedb)
      shift
      TEXT_DB=$1
      shift
      ;;
    -t | --targetdb)
      shift
      FORMAT_DB=$1
      shift
      ;;
    -f | --format)
      shift
      TBL_FORMAT=$1
      shift
      ;;
    -d | --delete)
      shift
      DELETE_MODE=$1
      shift
      ;;
    -l | --location)
      shift
      LOCATION_HDFS=$1
      shift
      ;;
    -c | --command)
      shift
      EXEC_COMMAND=$1
      shift
      ;;
    --help)
      HELP=true
      shift
      ;;
    *)
      echo "Invalid args: $1"
      exit 1
      ;;
  esac
done 

[ "$HELP" == "true" ] && usage && exit 0

if [ 'X'$TEXT_DB == 'X' ]; then
  usage
  exit 1
fi
if [ 'X'$FORMAT_DB == 'X' ]; then
  usage
  exit 1
fi

if [ 'X'$TBL_FORMAT == "Xflat" ]; then
  echo "This script is designed to generate none flat tables!"
  exit 1
fi

if [ 'X'$DELETE_MODE == "Xtrue" ] && [ X"$LOCATION_HDFS" == "X" ]; then 
  echo "LOCATION_HDFS is needed when DELETE_MODE is true."
  usage
  exit 1
fi

# Tables in the TPC-DS schema.
LIST="date_dim time_dim item customer customer_demographics 
      household_demographics customer_address store promotion 
      warehouse ship_mode reason income_band call_center 
      web_page catalog_page inventory store_sales store_returns
      web_sales web_returns web_site catalog_sales catalog_returns"

case $TBL_FORMAT in
  orc)
    # Do nothing recently.
  ;;
  flat)
    # Do nothing recently.
  ;;
  *)
    echo "Invalid format, only orc, text are supported recently."
    exit 1
  ;;
esac

[ ! 'X'$DELETE_MODE == 'Xtrue' ] && [ ! 'X'$DELETE_MODE == 'Xfalse' ] && echo "Invalid DELETE_MODE, true or false is expected while got $DELETE_MODE" &&  exit 1

if [ 'X'$INTEGRATE_MODE != "Xtrue" ]; then
  if [ 'X'$DELETE_MODE == "Xtrue" ]; then
    read -p "You are creating ${TBL_FORMAT} tables and the database name is \
$FORMAT_DB. After all, all tables in $TEXT_DB is droped and related files in \
HDFS are removed, is that OK [Yes|No]? " CONFIRM 
  elif [ 'X'$DELETE_MODE == "Xfalse" ]; then
    read -p "You are creating ${TBL_FORMAT} tables and the database name is \
$FORMAT_DB. After all, all tables in $TEXT_DB and related files in HDFS are \
reserved, is that OK [Yes|No]? " CONFIRM
  fi
  [ 'X'$CONFIRM != "XYes" ] && echo "Your answer is not Yes, check tpcds-env.sh and run again." && exit 1
fi

if [ "X$EXEC_COMMAND" != "X" ];then
  echo "Creating database..."
  $EXEC_COMMAND -e "create database if not exists $FORMAT_DB;" > /dev/null 2>&1
  for t in $LIST; do
    echo "Creating table $t..."
    $EXEC_COMMAND --database $FORMAT_DB -e "create table if not exists $t stored as $TBL_FORMAT as select * from $TEXT_DB.$t;" > /dev/null 2>&1
    [ 'X'$DELETE_MODE == "Xtrue" ] && $EXEC_COMMAND --database $TEXT_DB -e "drop table if exists $t;" > /dev/null 2>&1
  done
  [ 'X'$DELETE_MODE == "Xtrue" ] && $EXEC_COMMAND -e "drop database if exists $TEXT_DB;" > /dev/null 2>&1
else
  echo "Exec command is not specified."
  exit 1
fi

if [ $DELETE_MODE == "true" ]; then
  hdfs dfs -rm -r -f $LOCATION_HDFS
fi
