# Copyright reserved by www.transwarp.io, 2015
#!/bin/bash

basedir=$(dirname $0)
read -p "Please input hostname or ip address of hive server, if not needed, press ENTER:" HIVE_SERVER

which hive &> /dev/null
if [ "$?" -eq "0" ]; then
  if [ "X$HIVE_SERVER" != "X" ]; then
    command="hive -t -h $HIVE_SERVER"
  else
    command="hive"
  fi
else
  echo "No command: hive found!"
  exit 1
fi
echo "export CMD=$command" > $basedir/tpcds_env

read -p "Please input data scale(in GB) for tpcds:" TPCDSDATASCALE
read -p "Please input hdfs location to put text files generated for tpcds:" TPCDSDFSLOCATION
read -p "Please input table format(text | orc | rcfile) for tpcds:" TPCDSDATAFORMAT
read -p "Please input whether to delete text files in HDFS and drop text tables after tables of other format have been created[true | false] in tpcds test:" DELOPT
echo "export TPCDS_DATA_SCALE=$TPCDSDATASCALE" >> $basedir/tpcds_env
echo "export TPCDS_DFS_LOCATION=$TPCDSDFSLOCATION" >> $basedir/tpcds_env
echo "export TPCDS_DATA_FORMAT=$TPCDSDATAFORMAT" >> $basedir/tpcds_env
echo "export DEL_OPT=$DELOPT" >> $basedir/tpcds_env

