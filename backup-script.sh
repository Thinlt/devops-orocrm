#!/bin/bash

BACKUP_DIR=/backup/orocrm
MAX_FILES=30

if [ ! -d $BACKUP_DIR ]; then
  mkdir -p $BACKUP_DIR
fi

## backup main orocrm container
docker commit -p orocrm magestore/orocrm

## backup orocrm database
#docker commit -p orodatabase magestore/orocrm_database

## save backup source code file

DATE=$( date +%d )
MONTH=$( date +%Y%m )
TIME=$( date +%H%M%S )

BACKUP_CODE_FILE=$BACKUP_DIR/magestore_orocrm_$(echo $MONTH).tar
if [ ! -f $BACKUP_CODE_FILE ]; then
  docker save -o $BACKUP_CODE_FILE magestore/orocrm
fi

## remove saved backup database file

FILE_PREFIX="magestore_orodatabase"
NUM_FILES=$(ls -l $BACKUP_DIR | grep $FILE_PREFIX | wc -l)
OVER=$(( NUM_FILES - MAX_FILES ))
if [ $OVER -gt 0 ]; then
  ls $BACKUP_DIR | grep $FILE_PREFIX | sort | head -n $OVER | xargs -I %s rm $BACKUP_DIR/%s
fi

## save backup database file
#docker save -o $BACKUP_DIR/"$FILE_PREFIX"_$MONTH"$DATE"_$TIME.tar magestore/orocrm_database

docker run -it -v orocrm_data:/volume -v $BACKUP_DIR:/backup alpine \
   tar -cjf /backup/"$FILE_PREFIX"_$MONTH"$DATE"_$TIME.tar.bz2 -C /volume ./

