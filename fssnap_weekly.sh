#!/bin/bash

LAST=$(ls -t /home/remotebkp/qi/zodb/archived-* | head -n1)

if [ -n "$LAST" ]; then
    DATE=$(stat -c "%y" $LAST | cut -d" " -f1)
    DEST=/home/remotebkp/qi/zodb/weekly-$DATE.fs.bz2
    echo "CREATING WEEKLY SNAPSHOT FOR $DATE."
    cp $LAST $DEST
fi

echo "REMOVING ANY STALE WEEKLY SNAPSHOTS (>90 days old)."
rm $(find /home/remotebkp/qi/zodb -maxdepth 1 -type f -mtime +90 | grep weekly)

echo "DONE"

