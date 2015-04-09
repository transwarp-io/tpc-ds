#!/bin/bash
source tpcds-env.sh

echo "********************************************************************"
echo "*****          Generate data by run mapreduce routine          *****"
echo "****           hadoop jar tpcds-gen.jar -d XXX -s XXX           ****"
echo "********************************************************************"

function usage {
  echo "Usage: $0 
  -s | --scale, scale(in GB)
  -l | --locate, HDFS directory for falt files.
  -h | --help, Show this help message."
}

while [ $# -gt 0 ]; do
  case "$1" in
    -s | --scale)
      shift
      TPCDS_SCALE=$1
      shift
      ;;
    -l | --location)
      shift
      LOCATION_HDFS=$1
      shift
      ;;
    -h | --help)
      HELP=true
      shift
      ;;
    *)
      echo "Invalid args: $1"
      exit 1
      ;;
  esac
done

[ "$HELP" == "true" ] && usage && exit 1

if [ ! -f $PROJ_HOME/generator/target/tpcds-gen-1.1.jar ]; then
  echo "tpcds-gen-1.1.jar not found, Build the data generator with\
 build.sh first or make sure tpcds-env.sh is modified correctly."
  exit 1
fi

which hadoop > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Script must be run where hadoop is installed"
  exit 1
fi

# Ensure arguments exist.
if [ X"$TPCDS_SCALE" = "X" ]; then
  usage && exit 1
fi
if [ X"$LOCATION_HDFS" = "X" ]; then
  # Default location in hdfs.
  LOCATION_HDFS=/user/`whoami`/tpcds
fi

# Sanity checking.
if [ $TPCDS_SCALE -lt 1 ]; then
  echo "Scale factor cannot be less than 1"
  exit 1
fi

if [ 'X'$INTEGRATE_MODE != "Xtrue" ]; then
  read -p "You are generating ${TPCDS_SCALE}g tpcds data and then store it at HDFS directory ${LOCATION_HDFS}, disk usage of HDFS will be ${TPCDS_SCALE}g, is that OK [Yes|No]? " CONFIRM 
  [ 'X'$CONFIRM != "XYes" ] && echo "Your answer is not Yes, check tpcds-env.sh and your HDFS storage and run again." && exit 1
fi
hdfs dfs -mkdir -p ${LOCATION_HDFS}
hdfs dfs -ls ${LOCATION_HDFS}/${TPCDS_SCALE} > /dev/null 2>&1 || (cd $PROJ_HOME/generator; hadoop jar target/tpcds-gen-*.jar -d ${LOCATION_HDFS}/${TPCDS_SCALE}/ -s ${TPCDS_SCALE})
hdfs dfs -ls ${LOCATION_HDFS}/${TPCDS_SCALE}
