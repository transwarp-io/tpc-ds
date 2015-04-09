#!/bin/bash
# Environment of tpcds-gen and tpcds table created. Please modifiy it if needed

# PROJ_HOME
PROJ_BIN=$(dirname "${BASH_SOURCE-$0}")
PROJ_HOME=$(cd "$PROJ_BIN"/..; pwd)

# TPCDS Scale in GB
export TPCDS_SCALE=2
# Exec command
export EXEC_COMMAND="hive"

export TEXT_DB=tpcds_text_"$TPCDS_SCALE"
# Table format we need. only orc, flat, parquet are supported recently.
export TBL_FORMAT=orc
export FORMAT_DB=tpcds_"$TBL_FORMAT"_"$TPCDS_SCALE"
# Delete or not the text file in HDFS.
export DELETE_MODE=true

