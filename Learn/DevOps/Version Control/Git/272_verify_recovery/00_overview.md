## Overview

echo "Verifying recovery" | tee -a $LOG_FILE
git clone git@$PRIMARY_SERVER:enterprise/$TEST_REPO.git recovered-repo
cd recovered-repo
if grep -q "Test content" test-file.txt; then
  echo "RECOVERY TEST PASSED: Content verified" | tee -a $LOG_FILE
else
  echo "RECOVERY TEST FAILED: Content missing" | tee -a $LOG_FILE
fi

