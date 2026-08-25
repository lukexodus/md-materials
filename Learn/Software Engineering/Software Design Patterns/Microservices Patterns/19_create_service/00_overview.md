## Overview

aws servicediscovery create-service \
  --name payment-service \
  --namespace-id ns-xxxxx \
  --dns-config "NamespaceId=ns-xxxxx,DnsRecords=[{Type=A,TTL=60}]" \
  --health-check-custom-config FailureThreshold=1

