#!/bin/bash

# fetch filestorage archives on teamspace.upiq.org via rsync, then
# delete anything older than 14 days

HOST=qits1.upiq.org

# download qi database backups, exclude BLOBs:
echo "PULLING: database (ODB, SQL) storages, binary dumps (excluding BLOBs)."
rsync -avx --exclude "**blobsnapshot.*/" \
  -e "ssh -C -i /home/qi/.ssh/id_qit2backup_rsa" \
  --numeric-ids qi@$HOST:/home/remotebkp/qi/zodb/ \
  /home/remotebkp/qi/zodb/

echo "Done with sync of FileStorage archives from teamspace.upiq.org"

echo "Removing daily archived filestorage older than 14 days"
rm $(find /home/remotebkp/qi/zodb -maxdepth 1 -type f -mtime +14 | grep archived)

echo "DONE"

