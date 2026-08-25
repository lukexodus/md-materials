## Overview

echo "Initiating recovery process" | tee -a $LOG_FILE
ssh admin@$BACKUP_SERVER "gitlab-rake gitlab:backup:restore BACKUP=latest"

