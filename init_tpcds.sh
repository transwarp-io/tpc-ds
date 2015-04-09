# Copyright reserved by www.transwarp.io, 2015
#!/bin/bash

basedir=$(pwd)
source $basedir/tpcds_env

cd $basedir/init/bin
bash all-in-one.sh -s $TPCDS_DATA_SCALE -l $TPCDS_DFS_LOCATION -f $TPCDS_DATA_FORMAT -d $DEL_OPT -c $CMD
