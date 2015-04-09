# Copyright reserved by www.transwarp.io, 2015
#!/bin/bash

basedir=$(pwd)
source $basedir/tpcds_env
read -p "Do you want to verify result or not, only support 2G data scale[Yes | No]:" OPT
read -p "Please input database name to run:" DB

cd $basedir/tpcds_test
sed s/DATABASE/${DB}/g ./conf/config > /tmp/config

shopt -s nocasematch
case $OPT in 
  yes | y)
    perl run_test.pl -i /tmp/config -r $CMD -c
  ;;
  no | n)
    perl run_test.pl -i /tmp/config -r $CMD
  ;;
  *)
    echo "Wrong option!"
    exit 1
  ;;
esac
shopt -n nocasematch
