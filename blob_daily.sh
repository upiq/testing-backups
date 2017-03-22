#!/bin/bash

# N-pass incremental snapshot directory backup using rsync and cp -al.

DESTBASE=/home/remotebkp/qi/zodb/blob
TARGET="$DESTBASE/blobsnapshot"
KEEPN=10
HOST=qits1.upiq.org

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

#/usr/bin/rsync -a --delete --numeric-ids $SOURCEDIR/ $TARGET.0

# download qi ZODB blob backups: only latest BLOB dir, with --delete, to
# keep a verbatim copy of the tree without any stale stuff kept around.
echo "PULLING: ZODB BLOB (file) tree (deletes stale local copies)."
rsync -avxz -e "ssh -i /home/qi/.ssh/id_qit2backup_rsa" \
  --exclude "tmp/*" \
  --numeric-ids --delete qi@$HOST:/home/remotebkp/qi/zodb/blob/blobsnapshot.0/ \
  $TARGET.0/

echo "Completed rsync snapshot backup of blobs"

