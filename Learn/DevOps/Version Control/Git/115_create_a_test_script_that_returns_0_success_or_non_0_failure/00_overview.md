## Overview

echo '#!/bin/bash
npm test -- --grep="authentication test"
exit $?
' > test-script.sh
chmod +x test-script.sh

