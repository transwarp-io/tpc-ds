#!/bin/bash
echo "********************************************************************"
echo "*****   Create tpcds tables in gaven file format            ********"
echo "** 1. run gen-data.sh to gen text file into hdfs             *******"
echo "** 2. run create-text-table.sh to create text tables         *******"
echo "** 3. run create-none-text-table.sh to create given format tables **"
echo "** 4. delete text file in hdfs and drop text tables if needed ******"
echo "********************************************************************"

function usage() {
  echo "Usage: $0 
  -s | --scale scale(in GB) 
  -d | --delete [true | false] delete text file in hdfs and drop text tables or not, true by default,
  -f | --format [text | rcfile | orc ], text by default,
  -l | --location the location where the tpcds-text file located, /user/`whoami`/tpcds-text by default,
  -p | --partition [true | fales] partition or not. false by default,
  -c | --command, hive by default
  --help show help message."
}

# Integrate mode
export INTEGRATE_MODE=true

while [ $# -gt 0 ]; do
  case "$1" in
    -s | --scale)
      shift
      TPCDS_SCALE=$1
      shift
      ;;
    -d | --delete)
      shift
      DELETE_MODE=$1
      shift
      ;;
    -f | --format)
      shift
      TBL_FORMAT=$1
      shift
      ;;
    -l | --location)
      shift
      LOCATION_HDFS=$1
      shift
      ;;
    -c | --command)
      shift
      $EXEC_COMMAND=$1
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

if [ X"$TPCDS_SCALE" == "X" ]; then 
  echo "TPCDS_SCALE is needed."
  exit 1
fi

if [ X"$TBL_FORMAT" == "X" ]; then
  TBL_FORMAT=flat
fi

if [ X"$DELETE_MODE" == "X" ]; then
  DELETE_MODE=true
fi

read -p "You are running All in one script to creating tcpds ${TPCDS_SCALE}g \
dataset. the target format is $TBL_FORMAT and target database is $FORMAT_DB, \
all tables in $TEXT_DB is droped \
and related files in HDFS are removed if DELETE_MODE is true, recently it \
is $DELETE_MODE, is that OK [Yes|No]? " CONFIRM
[ ! 'X'$CONFIRM == "XYes" ] && echo "Your answer is not Yes, check \
tpcds-env.sh and your HDFS storage and run again." && exit 1

./gen-data.sh -s $TPCDS_SCALE -l $LOCATION_HDFS &&
./create-text-table.sh -l $LOCATION_HDFS -t $TEXT_DB -c $EXEC_COMMAND &&
[ ! $TBL_FORMAT == flat ] &&
./create-none-text-table.sh -s $TEXT_DB -t $FORMAT_DB -f $TBL_FORMAT -c $EXEC_COMMAND -d $DELETE_MODE -l $LOCATION_HDFS
