#!/bin/bash

LAST=$(ls -t /home/remotebkp/qi/zodb/archived-* | head -n1)

if [ -n "$LAST" ]; then
    DATE=$(stat -c "%y" $LAST | cut -d" " -f1)
    DEST=/home/remotebkp/qi/zodb/monthly-$DATE.fs.bz2
    echo "CREATING MONTHLY SNAPSHOT FOR $DATE."
    cp $LAST $DEST
fi

echo "REMOVING ANY STALE MONTHLY SNAPSHOTS (>190 days old)."
rm $(find /home/remotebkp/qi/zodb -maxdepth 1 -type f -mtime +190 | grep monthly)

echo "DONE"

