#!/bin/bash

# N-pass incremental snapshot directory backup using cp -al, sourced from
# last daily snapshot (created in daily script, by rsync).

DESTBASE=/home/remotebkp/qi/zodb/blob
SOURCEDIR="$DESTBASE/blobsnapshot.0"
TARGET="$DESTBASE/blobsnapshot-weekly"
KEEPN=10

if [ ! -d $DESTBASE ]; then mkdir -p $DESTBASE; fi

for ((i=$KEEPN; i >= 0; i--))
do
    if [ -d $TARGET.$i ]
    then
        if [ $i -eq $KEEPN ]
        then
            # mv $TARGET.N (last dir) to $TARGET.tmp for later recycling/reuse
            mv $TARGET.$i $TARGET.tmp
        else
            mv $TARGET.$i "$TARGET.$(expr $i + 1)"
        fi
    fi
done
# if $TARGET.tmp does not exist, create it
if [ ! -d $TARGET.tmp ]
then
    echo "CREATING: $TARGET.tmp"
    mkdir $TARGET.tmp
fi
# recycle $TARGET.tmp into $TARGET.0 for an rsync backup
mv $TARGET.tmp $TARGET.0
# Re-link existing copies of files using hard links via cp -al from $TARGET.1
if [ -d $TARGET.1 ]
then
    cp -al $TARGET.1/. $TARGET.0
fi

echo "PULLING: ZODB BLOB (file) tree from last daily snapshot."
cp -al $SOURCEDIR/. $TARGET.0

echo "Completed weekly snapshot backup of blobs"

