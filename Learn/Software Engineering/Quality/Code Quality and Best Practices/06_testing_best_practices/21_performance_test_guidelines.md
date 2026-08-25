## Performance test guidelines


**Key Points**

- **Metric Selection and Service Level Objectives (SLOs):**
    
    - **Percentiles over Averages:** Avoid relying on average response times, which mask outliers. Focus on p95, p99, and p99.9 latency metrics to understand the experience of the slowest 5% or 1% of users.
        
    - **Throughput vs. Latency:** Measure _Requests Per Second (RPS)_ to determine capacity, but correlate it with _Latency_ to ensure the system isn't just serving errors quickly.
        
    - **Resource Saturation:** Monitor CPU, Memory, Disk I/O, and Network Bandwidth to identify the hardware bottleneck (the "saturation point").
        
- **Workload Modeling:**
    
    - **Closed vs. Open Models:** Understand the difference between _Closed Systems_ (fixed number of concurrent users, new requests wait for completion) and _Open Systems_ (new requests arrive regardless of system state, typical of public APIs).
        
    - **Think Time:** Incorporate realistic delays between user actions. Zero-delay loops create artificial pressure that does not reflect production usage patterns.
        
    - **Data Cardinality:** Ensure test data has sufficient variety. Testing with a single cached record yields vastly different performance than testing with millions of unique records (which stresses cache eviction and database indexes).
        
- **Test Types:**
    
    - **Load Testing:** Verifies behavior under expected peak load.
        
    - **Stress Testing:** Identifies the breaking point and recovery mechanism (graceful degradation vs. crash).
        
    - **Soak/Endurance Testing:** Runs load for extended periods (e.g., 24+ hours) to detect memory leaks, connection pool exhaustion, and resource fragmentation.
        
    - **Spike Testing:** Tests the system's ability to scale up (auto-scaling triggers) and scale down rapidly.
        
- **Environment Parity and Isolation:** Performance tests must run in an environment that mirrors production hardware and network topology. Isolate the environment to prevent "noisy neighbor" interference from affecting results.
    
- **Coordinated Omission:** Be aware of testing tools that inadvertently pause load generation during system stalls, effectively omitting the worst response times from the final report. Asynchronous, non-blocking load generators are preferred to avoid this.
    
- **Code-Level Profiling:** Integrate Application Performance Monitoring (APM) agents during tests. High latency is a symptom; flame graphs and transaction traces provide the root cause (e.g., N+1 query problems, inefficient serialization).
    

**Example**

The following example uses **k6**, a modern, Go-based load testing tool that uses JavaScript for scripting. It demonstrates the "Test as Code" philosophy, defining strict failure criteria (thresholds) directly in the script.

_Scenario: Testing a Login Endpoint with specific SLOs._

JavaScript

```
import http from 'k6/http';
import { check, sleep } from 'k6';

// 1. Configuration
export const options = {
  stages: [
    { duration: '30s', target: 20 }, // Ramp up to 20 users
    { duration: '1m', target: 20 },  // Stay at 20 users
    { duration: '10s', target: 0 },  // Ramp down
  ],
  thresholds: {
    // 2. Failure Criteria (SLOs)
    // 95% of requests must complete below 200ms
    http_req_duration: ['p(95)<200'], 
    // Error rate must be less than 1%
    http_req_failed: ['rate<0.01'], 
  },
};

export default function () {
  const payload = JSON.stringify({
    username: 'test_user',
    password: 'secure_password',
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  // 3. Execution
  const res = http.post('https://api.example.com/v1/login', payload, params);

  // 4. Verification (Functional check during load)
  check(res, {
    'is status 200': (r) => r.status === 200,
    'token present': (r) => r.json('token') !== undefined,
  });

  // Simulate "Think Time"
  sleep(1); 
}
```

**Output**

When executed, k6 provides a terminal summary. Notice how the thresholds determine the pass/fail state of the CI pipeline.

Plaintext

```
  ...
  ✓ is status 200
  ✓ token present

  checks.........................: 100.00% ✓ 1345 ✗ 0
  data_received..................: 2.4 MB  20 kB/s
  data_sent......................: 840 kB  7.1 kB/s
  http_req_blocked...............: avg=2.34ms  min=1µs     med=2µs     max=134ms p(90)=4µs     p(95)=6µs    
  http_req_connecting............: avg=1.23ms  min=0s      med=0s      max=89ms  p(90)=0s      p(95)=0s     
  http_req_duration..............: avg=145.2ms min=112ms   med=138ms   max=450ms p(90)=189ms   p(95)=215ms  
    { expected_response:true }...: avg=145.2ms min=112ms   med=138ms   max=450ms p(90)=189ms   p(95)=215ms  
  ✗ http_req_failed..............: 0.00%   ✓ 0    ✗ 1345
  http_reqs......................: 1345    11.4502/s
  iteration_duration.............: avg=1.15s   min=1.11s   med=1.14s   max=1.56s p(90)=1.20s   p(95)=1.24s  
  iterations.....................: 1345    11.4502/s
  vus............................: 1       min=1  max=20
  vus_max........................: 20      min=20 max=20

ERRO[0122] some thresholds have failed
```

_Analysis:_ In this output, the test **failed** because the `p(95)` duration was 215ms, which exceeded the defined threshold of 200ms, despite a 0% error rate.

**Conclusion**

Effective performance testing moves beyond simple "stress" scenarios to precise measurement of system behavior against defined Service Level Objectives. By integrating these tests into the CI/CD pipeline ("Shift-Left Performance"), teams prevent performance regressions from merging into the main branch, ensuring that scalability and responsiveness are treated as first-class quality attributes alongside functional correctness.

---

