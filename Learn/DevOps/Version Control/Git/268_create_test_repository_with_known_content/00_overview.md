## Overview

echo "Creating test repository" | tee -a $LOG_FILE
mkdir -p $TEST_REPO
cd $TEST_REPO
git init
echo "Test content" > test-file.txt
git add test-file.txt
git commit -m "Initial commit"
git remote add origin git@$PRIMARY_SERVER:enterprise/$TEST_REPO.git
git push -u origin main

