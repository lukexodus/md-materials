## Overview

curl http://consul-server:8500/v1/catalog/service/user-service
```

**Use Cases:**

- Multi-region deployments
- Hybrid cloud environments
- Organizations needing service mesh features
- Teams wanting DNS-based discovery

#### Eureka

Netflix's service registry, part of the Spring Cloud ecosystem.

**Features:**

- Self-preservation mode (continues working during network partitions)
- Client-side caching
- Built-in dashboard
- Strong Spring Boot integration
- Regional failover support

**Registration Example:**

```yaml
eureka:
  client:
    serviceUrl:
      defaultZone: http://eureka-server:8761/eureka/
  instance:
    instanceId: ${spring.application.name}:${random.value}
    leaseRenewalIntervalInSeconds: 10
    metadata-map:
      version: 1.2.0
      region: us-west-2
```

**Discovery Example:**

```java
@Autowired
private EurekaClient eurekaClient;

public ServiceInstance getServiceInstance(String serviceName) {
    InstanceInfo instance = eurekaClient
        .getNextServerFromEureka(serviceName, false);
    return new ServiceInstance(
        instance.getHostName(),
        instance.getPort()
    );
}
```

**Use Cases:**

- Spring Boot microservices
- Organizations already using Netflix OSS stack
- AWS deployments
- Teams needing self-preservation during network issues

#### etcd

Distributed key-value store often used for service discovery in Kubernetes.

**Features:**

- Strong consistency (Raft consensus)
- Watch API for real-time updates
- TTL-based key expiration
- High performance
- Small footprint

**Registration Example:**

```bash
