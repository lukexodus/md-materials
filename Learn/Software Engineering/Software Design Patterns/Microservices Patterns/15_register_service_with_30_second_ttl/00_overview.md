## Overview

etcdctl put /services/payment-service/instance-1 \
  '{"host":"10.0.1.5","port":8080}' --lease=<lease-id>

