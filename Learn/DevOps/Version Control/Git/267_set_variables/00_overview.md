## Overview

PRIMARY_SERVER="git.example.com"
BACKUP_SERVER="git-backup.example.com"
TEST_REPO="test-recovery-repo"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
LOG_FILE="recovery-test-$TIMESTAMP.log"

echo "Starting recovery test at $(date)" | tee -a $LOG_FILE

