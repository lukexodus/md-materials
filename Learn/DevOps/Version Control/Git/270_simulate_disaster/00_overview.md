## Overview

echo "Simulating disaster by removing repository" | tee -a $LOG_FILE
curl -X DELETE -H "Authorization: token $TOKEN" \
     https://$PRIMARY_SERVER/api/v3/repos/enterprise/$TEST_REPO

