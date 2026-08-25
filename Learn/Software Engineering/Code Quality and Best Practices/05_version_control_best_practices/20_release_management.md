## Release management


Release management is the governance function responsible for planning, scheduling, and controlling the movement of releases to test and live environments. It transitions the focus from "code completion" to "service delivery," ensuring that the integrity of the live environment is protected and that the correct components are released.

**Key Points**

- **Immutable Artifacts:**
    
    - **The Golden Rule:** "Build once, deploy many."
        
    - Never rebuild the application for a specific environment (e.g., do not have a separate build command for Staging vs. Production).
        
    - Instead, generate a single binary, Docker image, or package during the build phase. This exact artifact is promoted through environments (Dev → QA → Stage → Prod).
        
    - Configuration (database URLs, API keys) must be injected at runtime (via environment variables), not baked into the build. This guarantees that the code tested in QA is bit-for-bit identical to the code running in Production.
        
- **Decoupling Deployment from Release:**
    
    - **Deployment:** The technical act of moving code to a server.
        
    - **Release:** The business act of making features available to users.
        
    - Using **Feature Flags (Toggles)** allows code to be deployed to production safely while remaining dormant (hidden) from users. This enables "Dark Launches" and separates the risk of technical deployment from the risk of user adoption.
        
- **Release Strategies:**
    
    - **Blue/Green Deployment:** Two identical environments exist. "Blue" is live. You deploy the new version to "Green" (idle). Once verified, the router switches all traffic from Blue to Green. Instant rollback is possible by switching back.
        
    - **Canary Releases:** A small percentage of traffic (e.g., 5%) is routed to the new version. Metrics (error rates, latency) are monitored. If stable, traffic is gradually increased to 100%. If unstable, traffic is cut immediately.
        
    - **Rolling Updates:** Instances of the old version are replaced one by one with the new version.
        
- **Semantic Versioning (SemVer) Enforcement:**
    
    - Releases must carry a unique identifier adhering to `MAJOR.MINOR.PATCH`.
        
    - **Major:** Incompatible API changes.
        
    - **Minor:** Backwards-compatible functionality.
        
    - **Patch:** Backwards-compatible bug fixes.
        
    - This is not just for marketing; automated dependency managers rely on this contract to prevent breaking builds.
        
- **The Release Gate/Approval:**
    
    - While Continuous Integration (CI) should be automated, Continuous Delivery (CD) to production often requires a "Gate."
        
    - This can be automated (e.g., "Passes all integration tests and performance benchmarks") or manual (e.g., "Product Owner click to approve").
        
- **Post-Release Monitoring:**
    
    - A release is not finished when the deployment script exits successfully. It is finished when the "Burn-in" period passes without distinct shifts in observability metrics (error spikes, CPU usage, customer support tickets).
        

**Example**

**A GitOps-based Release Workflow:**

1. **Trigger:** Developer pushes a git tag `v2.1.0`.
    
2. **CI Pipeline:**
    
    - Runs unit tests and linters.
        
    - Builds Docker image `myapp:v2.1.0`.
        
    - Pushes image to Container Registry.
        
3. **CD Pipeline (Staging):**
    
    - Detects new image. Updates the Staging Kubernetes manifest to use `myapp:v2.1.0`.
        
    - Runs automated smoke tests against Staging.
        
4. **Gate:** Pipeline pauses. Notification sent to slack: "Staging verified. Approve release to Production?"
    
5. **CD Pipeline (Production):**
    
    - Engineer clicks "Approve."
        
    - **Canary Phase:** 5% of traffic routed to `v2.1.0`.
        
    - **Analysis:** Prometheus checks error rates for 10 minutes.
        
    - **Rollout:** If healthy, traffic expands to 100%. If unhealthy, traffic reverts to 0%.

---

